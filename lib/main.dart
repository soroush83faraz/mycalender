import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'firebase_options.dart';
import 'providers/calendar_provider.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService.instance.handleRedirectResult();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalendarProvider()..loadData(),
      child: Consumer<CalendarProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'تقویم فارسی',
            debugShowCheckedModeBanner: false,
            locale: const Locale('fa', 'IR'),
            supportedLocales: const [
              Locale('fa', 'IR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: _buildLightTheme(provider.settings.primaryColor),
            darkTheme: _buildDarkTheme(provider.settings.primaryColor),
            themeMode: provider.settings.autoTheme
                ? ThemeMode.system
                : provider.settings.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
            home: const AuthGate(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme(String primaryColorHex) {
    final primaryColor =
        Color(int.parse(primaryColorHex.replaceFirst('#', '0xFF')));
    final baseTheme = ThemeData.light(useMaterial3: true);
    final textTheme = PersianFonts.vazirTextTheme.apply(
      bodyColor: baseTheme.colorScheme.onSurface,
      displayColor: baseTheme.colorScheme.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme(String primaryColorHex) {
    final primaryColor =
        Color(int.parse(primaryColorHex.replaceFirst('#', '0xFF')));
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final textTheme = PersianFonts.vazirTextTheme.apply(
      bodyColor: baseTheme.colorScheme.onSurface,
      displayColor: baseTheme.colorScheme.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = provider.currentUser;
        final shouldShowWelcome =
            user == null || (user.isAnonymous && provider.isGuestUiLoggedOut);
        return shouldShowWelcome ? const WelcomeScreen() : const MainScreen();
      },
    );
  }
}
