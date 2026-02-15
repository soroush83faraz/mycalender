# Rebuild steps for local-font Flutter Web runs.
flutter clean
flutter pub get
flutter run -d chrome
flutter build web --release