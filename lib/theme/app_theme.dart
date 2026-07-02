import 'package:flutter/material.dart';

/// Centralized design system for the app.
///
/// A single source of truth for typography, colors and component styling so
/// every screen looks consistent. Crucially, [fontFamily] is set on the whole
/// [ThemeData] (not only on [TextTheme]) so that *every* text — including
/// inline `TextStyle(...)` that omit a family — renders in Vazirmatn instead of
/// falling back to the platform default. This is what fixes the font that used
/// to change from screen to screen.
class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'Vazirmatn';
  static const List<String> _fallback = <String>['Roboto'];

  /// Corner radius used across cards, sheets and inputs.
  static const double radius = 18;

  static Color _parseColor(String hex) {
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  static ThemeData light(String primaryColorHex) =>
      _build(Brightness.light, _parseColor(primaryColorHex));

  static ThemeData dark(String primaryColorHex) =>
      _build(Brightness.dark, _parseColor(primaryColorHex));

  static ThemeData _build(Brightness brightness, Color seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      fontFamilyFallback: _fallback,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
    );

    final textTheme = _persianTextTheme(base.textTheme, scheme.onSurface);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 2,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        selectedLabelTextStyle:
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: textTheme.labelLarge,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide.none,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : null,
        ),
      ),
    );
  }

  /// Applies Vazirmatn with tuning that suits Persian text: comfortable line
  /// height and zero letter spacing (Persian must never be letter-spaced).
  static TextTheme _persianTextTheme(TextTheme base, Color color) {
    TextStyle? t(TextStyle? s, {double height = 1.4}) => s?.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: _fallback,
          color: color,
          letterSpacing: 0,
          height: height,
        );

    return TextTheme(
      displayLarge: t(base.displayLarge, height: 1.2),
      displayMedium: t(base.displayMedium, height: 1.2),
      displaySmall: t(base.displaySmall, height: 1.2),
      headlineLarge: t(base.headlineLarge, height: 1.3),
      headlineMedium: t(base.headlineMedium, height: 1.3),
      headlineSmall: t(base.headlineSmall, height: 1.3),
      titleLarge: t(base.titleLarge, height: 1.35),
      titleMedium: t(base.titleMedium),
      titleSmall: t(base.titleSmall),
      bodyLarge: t(base.bodyLarge, height: 1.5),
      bodyMedium: t(base.bodyMedium, height: 1.5),
      bodySmall: t(base.bodySmall, height: 1.5),
      labelLarge: t(base.labelLarge),
      labelMedium: t(base.labelMedium),
      labelSmall: t(base.labelSmall),
    );
  }
}
