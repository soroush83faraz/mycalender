import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
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
          final isEnglish = provider.settings.language == 'en';
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            locale: isEnglish
                ? const Locale('en', 'US')
                : const Locale('fa', 'IR'),
            supportedLocales: const [
              Locale('fa', 'IR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(provider.settings.primaryColor),
            darkTheme: AppTheme.dark(provider.settings.primaryColor),
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
