import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../l10n/app_localizations.dart';
import '../providers/calendar_provider.dart';
import '../services/location_service.dart';
import '../services/prayer_times_service.dart';
import '../utils/calendar_utils.dart';

/// Compass with qibla direction. Heading comes from a tilt-compensated
/// fusion of the accelerometer and magnetometer (same math as Android's
/// SensorManager.getRotationMatrix); the qibla bearing is the great-circle
/// bearing from the user's location to the Kaaba.
class CompassScreen extends StatefulWidget {
  const CompassScreen({Key? key}) : super(key: key);

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  Timer? _sensorTimeout;

  // Low-pass filtered sensor vectors.
  List<double>? _gravity;
  List<double>? _magnetic;

  double? _headingDegrees;
  double? _qiblaBearingDegrees;
  String? _locationLabel;
  bool _sensorUnavailable = false;

  @override
  void initState() {
    super.initState();
    _resolveQiblaBearing();
    _startSensors();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _sensorTimeout?.cancel();
    super.dispose();
  }

  void _startSensors() {
    // If neither sensor delivers within a few seconds (emulator, desktop,
    // devices without a magnetometer) show a friendly message instead of a
    // spinner forever.
    _sensorTimeout = Timer(const Duration(seconds: 4), () {
      if (mounted && _headingDegrees == null) {
        setState(() => _sensorUnavailable = true);
      }
    });

    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (event) {
          _gravity = _lowPass(_gravity, [event.x, event.y, event.z]);
          _updateHeading();
        },
        onError: (_) => _markUnavailable(),
        cancelOnError: true,
      );
      _magnetometerSubscription = magnetometerEventStream().listen(
        (event) {
          _magnetic = _lowPass(_magnetic, [event.x, event.y, event.z]);
          _updateHeading();
        },
        onError: (_) => _markUnavailable(),
        cancelOnError: true,
      );
    } catch (_) {
      _markUnavailable();
    }
  }

  void _markUnavailable() {
    if (mounted && !_sensorUnavailable) {
      setState(() => _sensorUnavailable = true);
    }
  }

  List<double> _lowPass(List<double>? previous, List<double> current) {
    const alpha = 0.15;
    if (previous == null) return current;
    return [
      previous[0] + alpha * (current[0] - previous[0]),
      previous[1] + alpha * (current[1] - previous[1]),
      previous[2] + alpha * (current[2] - previous[2]),
    ];
  }

  void _updateHeading() {
    final gravity = _gravity;
    final magnetic = _magnetic;
    if (gravity == null || magnetic == null) return;

    // H = M x A, the horizontal east axis of the device.
    final hx = magnetic[1] * gravity[2] - magnetic[2] * gravity[1];
    final hy = magnetic[2] * gravity[0] - magnetic[0] * gravity[2];
    final hz = magnetic[0] * gravity[1] - magnetic[1] * gravity[0];
    final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (normH < 0.1) return; // free fall or magnetic anomaly

    final invH = 1 / normH;
    final ex = hx * invH, ey = hy * invH, ez = hz * invH;

    final normA = math.sqrt(gravity[0] * gravity[0] +
        gravity[1] * gravity[1] +
        gravity[2] * gravity[2]);
    if (normA < 0.1) return;
    final invA = 1 / normA;
    final ax = gravity[0] * invA, az = gravity[2] * invA;

    // N = A x H, the horizontal north axis of the device.
    final ny = az * ex - ax * ez;

    final azimuth = math.atan2(ey, ny); // radians, clockwise from north
    final degrees = (azimuth * 180 / math.pi + 360) % 360;

    if (!mounted) return;
    setState(() {
      _headingDegrees = degrees;
      _sensorUnavailable = false;
    });
  }

  Future<void> _resolveQiblaBearing() async {
    final settings = context.read<CalendarProvider>().settings;

    double? latitude;
    double? longitude;
    String? label;

    if (settings.useDeviceLocation) {
      if (settings.latitude != null && settings.longitude != null) {
        latitude = settings.latitude;
        longitude = settings.longitude;
      } else {
        final location = await LocationService.getCurrentLocation();
        if (location != null) {
          latitude = location.latitude;
          longitude = location.longitude;
        }
      }
    }

    if (latitude == null || longitude == null) {
      final city = PrayerTimesService.coordinatesForCity(settings.location);
      latitude = city.latitude;
      longitude = city.longitude;
      label = city.name;
    }

    if (!mounted) return;
    setState(() {
      _qiblaBearingDegrees =
          _initialBearing(latitude!, longitude!, _kaabaLatitude, _kaabaLongitude);
      _locationLabel = label;
    });
  }

  /// Initial great-circle bearing from (lat1, lon1) to (lat2, lon2), in
  /// degrees clockwise from true north.
  double _initialBearing(
      double lat1, double lon1, double lat2, double lon2) {
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final deltaLambda = (lon2 - lon1) * math.pi / 180;
    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CalendarProvider>();
    final usePersian = provider.settings.showPersianNumbers;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.compass)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _sensorUnavailable
              ? _buildUnavailable(context)
              : _headingDegrees == null
                  ? const Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    )
                  : _buildCompass(context, usePersian),
        ),
      ),
    );
  }

  Widget _buildUnavailable(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.explore_off_outlined,
            size: 72, color: scheme.onSurface.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text(
          l10n.compassNotAvailable,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCompass(BuildContext context, bool usePersian) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final heading = _headingDegrees!;
    final qibla = _qiblaBearingDegrees;

    final qiblaDelta =
        qibla == null ? null : ((qibla - heading + 540) % 360) - 180;
    final facingQibla = qiblaDelta != null && qiblaDelta.abs() <= 5;

    String formatDegrees(double value) => CalendarUtils.formatNumber(
        '${value.round() % 360}°',
        usePersian: usePersian);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rose rotates opposite the device heading so north stays north.
              Transform.rotate(
                angle: -heading * math.pi / 180,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: _CompassRosePainter(
                    scheme: scheme,
                    qiblaBearingDegrees: qibla,
                    facingQibla: facingQibla,
                    labels: [
                      l10n.cardinalNorth,
                      l10n.cardinalEast,
                      l10n.cardinalSouth,
                      l10n.cardinalWest,
                    ],
                  ),
                ),
              ),
              // Fixed lubber line at the top of the dial.
              Positioned(
                top: 0,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 36,
                  color: facingQibla ? Colors.green : scheme.primary,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatDegrees(heading),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: facingQibla ? Colors.green : scheme.onSurface,
                    ),
                  ),
                  if (facingQibla)
                    Text(
                      l10n.facingQibla,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (qibla != null)
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mosque, size: 20, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    '${l10n.qiblaDirection}: ${formatDegrees(qibla)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_locationLabel != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.basedOnLocation(_locationLabel!),
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.compassCalibrationHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  _CompassRosePainter({
    required this.scheme,
    required this.qiblaBearingDegrees,
    required this.facingQibla,
    required this.labels,
  });

  final ColorScheme scheme;
  final double? qiblaBearingDegrees;
  final bool facingQibla;

  /// Cardinal labels in N, E, S, W order.
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final dialPaint = Paint()
      ..color = scheme.surfaceContainerHigh
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 4, dialPaint);

    final rimPaint = Paint()
      ..color = scheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 4, rimPaint);

    // Tick marks every 15 degrees, heavier on the cardinals.
    for (var degree = 0; degree < 360; degree += 15) {
      final isCardinal = degree % 90 == 0;
      final angle = (degree - 90) * math.pi / 180;
      final outer = radius - 10;
      final inner = outer - (isCardinal ? 16 : 8);
      final tickPaint = Paint()
        ..color = isCardinal
            ? (degree == 0 ? Colors.red.shade400 : scheme.onSurface)
            : scheme.onSurface.withValues(alpha: 0.35)
        ..strokeWidth = isCardinal ? 3 : 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        tickPaint,
      );
    }

    // Cardinal labels; north is red like a classic compass.
    for (var i = 0; i < 4; i++) {
      final degree = i * 90;
      final angle = (degree - 90) * math.pi / 180;
      final labelCenter = center +
          Offset(math.cos(angle) * (radius - 44),
              math.sin(angle) * (radius - 44));
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: i == 0 ? Colors.red.shade400 : scheme.onSurface,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      painter.paint(
          canvas,
          labelCenter - Offset(painter.width / 2, painter.height / 2));
    }

    // Qibla marker on the rim at its bearing.
    final qibla = qiblaBearingDegrees;
    if (qibla != null) {
      final angle = (qibla - 90) * math.pi / 180;
      final markerCenter = center +
          Offset(math.cos(angle) * (radius - 22),
              math.sin(angle) * (radius - 22));
      final markerPaint = Paint()
        ..color = facingQibla ? Colors.green : Colors.green.shade600;
      canvas.drawCircle(markerCenter, 12, markerPaint);

      final mosque = TextPainter(
        text: const TextSpan(
          text: '\u{1F54B}', // 🕋
          style: TextStyle(fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      mosque.paint(canvas,
          markerCenter - Offset(mosque.width / 2, mosque.height / 2));
    }

    // North needle.
    final needlePaint = Paint()..color = Colors.red.shade400;
    final needlePath = Path()
      ..moveTo(center.dx, center.dy - radius + 30)
      ..lineTo(center.dx - 7, center.dy - radius + 52)
      ..lineTo(center.dx + 7, center.dy - radius + 52)
      ..close();
    canvas.drawPath(needlePath, needlePaint);
  }

  @override
  bool shouldRepaint(_CompassRosePainter oldDelegate) =>
      oldDelegate.qiblaBearingDegrees != qiblaBearingDegrees ||
      oldDelegate.facingQibla != facingQibla ||
      oldDelegate.scheme != scheme;
}
