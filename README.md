# Persian Calendar App

**Live demo:** https://soroush83faraz.github.io/mycalender/

A beautiful Flutter application for displaying the Persian (Jalali) calendar with full support for date conversion, navigation, and selection.

## Features

- ✅ Complete Persian (Jalali) calendar display
- ✅ Gregorian to Jalali date conversion
- ✅ Month navigation with arrow buttons
- ✅ Day selection with visual feedback
- ✅ Persian number display
- ✅ Weekday names in Persian
- ✅ Leap year calculation for Jalali calendar
- ✅ Material 3 design support
- ✅ Dark and Light theme support
- ✅ Today button to return to current date

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 3.0 or higher)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/persian_calendar.git
cd persian_calendar
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # Entry point of the app
├── screens/
│   └── home_screen.dart     # Main calendar screen
├── widgets/
│   └── calendar_grid.dart   # Calendar grid widget
├── models/
│   └── jalali_date.dart     # Jalali date model
└── utils/
    └── calendar_utils.dart  # Utility functions for calendar operations
```

## How to Use

1. **Navigate Months**: Use the arrow buttons (← →) in the header to navigate between months
2. **Select a Day**: Tap on any day to select it
3. **View Day Info**: Selected day information appears at the bottom with the Persian weekday name
4. **Return to Today**: Press the FAB button (Today) to return to the current date

## Dependencies

- `flutter`: Flutter framework
- `cupertino_icons`: iOS-style icons
- `shamsi_date`: Jalali calendar library (optional, for alternative implementation)
- `intl`: Internationalization and localization library
- `provider`: State management library

## Features Explained

### Jalali Date Conversion
The app includes custom conversion algorithms between Gregorian and Jalali calendar systems, ensuring accurate date transformations.

### Persian Number Display
All numbers are automatically converted to Persian numerals (۰-۹) for better user experience.

### Leap Year Calculation
Proper Jalali leap year calculations to ensure Esfand (month 12) displays 30 days on leap years and 29 on regular years.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created with ❤️ for Persian calendar lovers
