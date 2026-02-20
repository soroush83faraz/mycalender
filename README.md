# Persian Calendar App

A beautiful Flutter application for displaying the Persian (Jalali) calendar with support for date conversion, navigation, and event management.

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)

### Install

```bash
git clone https://github.com/soroush83faraz/mycalender.git
cd mycalender
flutter pub get
```

## Beta Build

### Build commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

### Public beta checklist

- Verify cold start and first-run flow.
- Verify guest mode entry and usage.
- Verify Google sign-in and sign-out.
- Verify guest-to-Google upgrade flow.
- Verify month/week/year switching.
- Verify date navigation (next/previous/today).
- Verify add/edit/delete event flows.
- Verify settings persistence after app restart.
- Verify offline behavior with existing local data.
- Verify online sync behavior when connectivity returns.
- Verify no obvious crashes or severe UI jank.

### Bug report template

Include:

- Device model and Android version
- App version (`pubspec.yaml` version)
- Reproduction steps
- Expected result vs actual result
- Screenshot or screen recording (if possible)
