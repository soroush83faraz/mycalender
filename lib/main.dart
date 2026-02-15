import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/calendar_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const List<String> _fontFallbacks = [
    'NotoNastaliqUrdu',
    'Segoe UI',
    'Tahoma',
    'Arial',
    'sans-serif',
  ];

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
    final primaryColor = Color(int.parse(primaryColorHex.replaceFirst('#', '0xFF')));
    final baseTheme = ThemeData.light(useMaterial3: true);
    final textTheme = baseTheme.textTheme.apply(
      fontFamily: 'Roboto',
      fontFamilyFallback: _fontFallbacks,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      fontFamilyFallback: _fontFallbacks,
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
    final primaryColor = Color(int.parse(primaryColorHex.replaceFirst('#', '0xFF')));
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final textTheme = baseTheme.textTheme.apply(
      fontFamily: 'Roboto',
      fontFamilyFallback: _fontFallbacks,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
      fontFamilyFallback: _fontFallbacks,
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        return user != null ? const MainScreen() : const LoginScreen();
      },
    );
  }
}
