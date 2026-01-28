# Persian Calendar App - Memory Bank

## Project Overview
A comprehensive Flutter application displaying Persian (Jalali) calendar with advanced features including event management, date conversion, notifications, and multiple utility tools. Built with Material 3 design, provider state management, and supports both dark/light themes.

## Core Architecture

### File Structure
```
lib/
├── main.dart                     # App entry point with provider setup
├── screens/
│   ├── main_screen.dart         # Bottom navigation container
│   ├── calendar_screen.dart     # Modern calendar interface
│   ├── events_screen.dart       # Event management
│   ├── tools_screen.dart        # Utility tools
│   ├── settings_screen.dart     # App configuration
│   └── add_event_screen.dart    # Event creation/editing
├── widgets/
│   ├── modern_calendar_grid.dart # Enhanced calendar grid
│   ├── event_list_widget.dart   # Event display component
│   └── holiday_widget.dart      # Holiday display component
├── models/
│   ├── jalali_date.dart        # Core date model
│   ├── event.dart              # Event data model
│   ├── holiday.dart            # Holiday data model
│   └── settings.dart           # App settings model
├── providers/
│   └── calendar_provider.dart   # State management
├── services/
│   ├── notification_service.dart # Push notifications
│   └── date_conversion_service.dart # Multi-calendar conversion
└── utils/
    └── calendar_utils.dart      # Utility functions
```

## Implemented Features (MVP)

### ✅ Core Calendar Features
- **Cross-Platform**: Android & iOS support
- **Smooth Navigation**: Fluid month-to-month transitions
- **Quick Today**: Instant return to current date
- **Event Management**: Full CRUD operations for events
- **Daily Events**: View events for selected dates
- **Offline Storage**: Local data persistence
- **Modern UI/UX**: Material 3 design with animations

### ✅ Advanced Features
- **Multi-Language**: Persian/English support
- **Theme System**: Dark/Light/Auto modes with custom colors
- **Date Conversion**: Jalali ↔ Gregorian ↔ Hijri
- **Holiday System**: Official, religious, ancient, international
- **Event Countdown**: Days remaining calculations
- **Age Calculator**: Personal age and age difference tools
- **Date Difference**: Calculate time spans between dates
- **Notifications**: Event reminders with local notifications
- **Persian Numbers**: Full Persian numeral support
- **Settings**: Comprehensive configuration options

## Key Components Deep Dive

### 1. State Management (Provider Pattern)
**CalendarProvider** manages:
- Current/selected dates
- Event collection with CRUD operations
- App settings with persistence
- Holiday integration
- View state (month/week/year)

### 2. Event System
**Event Model Features**:
- Unique ID generation
- Title, description, category
- Color coding
- Reminder system with notifications
- JSON serialization for storage

**Categories**: Personal, Work, Family, Health, Education, Other

### 3. Holiday System
**Holiday Types**:
- **Official**: Nowruz, Revolution Day, Oil Nationalization
- **Religious**: Eid, Ashura, Prophet's Birthday
- **Ancient**: Yalda, Mehrgan, Tirgan, Sadeh
- **International**: Configurable international holidays

### 4. Modern Calendar Grid
**Visual Features**:
- Gradient headers with smooth animations
- Event indicators (colored dots)
- Holiday markers by type
- Today highlighting with border
- Selection feedback with shadows
- Responsive design

### 5. Notification System
**Capabilities**:
- Local notifications for event reminders
- Timezone-aware scheduling
- Custom notification channels
- Permission handling

## Technical Specifications

### Date Conversion Algorithms
**Jalali ↔ Gregorian**:
- Mathematical conversion using Julian Day Numbers
- Accurate leap year calculations
- Handles historical dates back to 1900

**Hijri Conversion**:
- Lunar calendar calculations
- Month name localization
- Accurate Islamic date representation

### Persian Localization
**Number System**: ۰۱۲۳۴۵۶۷۸۹
**Weekdays**: شنبه، یکشنبه، دوشنبه، سه‌شنبه، چهارشنبه، پنج‌شنبه، جمعه
**Months**: فروردین، اردیبهشت، خرداد، تیر، مرداد، شهریور، مهر، آبان، آذر، دی، بهمن، اسفند

### Storage Architecture
**SharedPreferences** for:
- Event data (JSON serialized)
- App settings
- User preferences
- Theme configurations

## UI/UX Design System

### Material 3 Implementation
- **Dynamic Color**: Seed-based color schemes
- **Typography**: Vazirmatn font family
- **Elevation**: Consistent shadow system
- **Animation**: Staggered list animations
- **Navigation**: Bottom navigation with 4 tabs

### Theme System
**Light Theme**:
- Primary color customization
- Surface-based layouts
- High contrast ratios

**Dark Theme**:
- Automatic dark color generation
- Reduced eye strain
- OLED-friendly blacks

### Responsive Design
- Adaptive layouts for different screen sizes
- Proper RTL support for Persian text
- Touch-friendly interactive elements

## Tools & Utilities

### 1. Date Converter
- Real-time conversion between calendar systems
- Visual date cards with icons
- Easy date selection interface

### 2. Age Calculator
- Personal age calculation
- Age difference between two people
- Years, months, days breakdown

### 3. Date Difference Tool
- Calculate spans between any two dates
- Multiple format outputs
- Historical date support

### 4. Countdown System
- Days remaining to events
- Visual countdown displays
- Automatic updates

### 5. World Clock (Planned)
- Multiple timezone support
- Major city clocks
- Prayer times integration

## Settings & Configuration

### Appearance Settings
- Theme mode (Auto/Light/Dark)
- Primary color customization
- Persian number toggle
- Font size preferences

### Display Options
- Gregorian calendar overlay
- Lunar calendar display
- Holiday visibility
- Event indicators

### Notification Settings
- Enable/disable notifications
- Default reminder times
- Notification sounds

### Calendar Preferences
- Default view (Month/Week/Year)
- Week start day
- Holiday categories
- Location for prayer times

## Performance Optimizations

### Memory Management
- Efficient date calculations
- Lazy loading of calendar data
- Proper widget disposal
- Cached Persian number conversions

### UI Performance
- IndexedStack for tab navigation
- Minimal rebuilds with Consumer widgets
- Optimized grid rendering
- Smooth animations with proper curves

### Storage Efficiency
- JSON compression for events
- Incremental data loading
- Background data persistence

## Testing Strategy

### Unit Tests
- Date conversion accuracy
- Persian number conversion
- Leap year calculations
- Event CRUD operations

### Widget Tests
- Calendar grid rendering
- Event list display
- Navigation functionality
- Theme switching

### Integration Tests
- End-to-end user workflows
- Data persistence
- Notification scheduling

## Future Enhancements

### Planned Features
- **Google Calendar Sync**: Two-way synchronization
- **Prayer Times**: Location-based Islamic prayer times
- **Weather Integration**: Daily weather in calendar
- **Backup/Restore**: Cloud data synchronization
- **Widget Support**: Home screen calendar widget
- **Export Options**: PDF/ICS export functionality

### Technical Improvements
- **Offline Maps**: For location-based features
- **Voice Commands**: Persian voice interaction
- **Accessibility**: Screen reader support
- **Performance**: Further optimization

## Development Guidelines

### Code Standards
- Dart/Flutter best practices
- Provider pattern for state management
- Comprehensive error handling
- Internationalization support

### Git Workflow
- Feature branch development
- Code review requirements
- Automated testing pipeline
- Semantic versioning

### Release Process
- Platform-specific builds
- App store optimization
- User feedback integration
- Performance monitoring

## Dependencies

### Core Dependencies
```yaml
flutter: sdk
provider: ^6.1.1                    # State management
shared_preferences: ^2.2.2          # Local storage
flutter_local_notifications: ^16.3.2 # Notifications
google_fonts: ^6.1.0               # Typography
flutter_colorpicker: ^1.0.3        # Color selection
flutter_staggered_animations: ^1.1.1 # Animations
```

### Utility Dependencies
```yaml
intl: ^0.19.0                      # Internationalization
timezone: ^0.9.2                   # Timezone handling
url_launcher: ^6.2.2               # External links
permission_handler: ^11.2.0        # Permissions
geolocator: ^10.1.0               # Location services
http: ^1.1.2                      # Network requests
```

## Troubleshooting Guide

### Common Issues
1. **Date Conversion Errors**: Check leap year calculations
2. **Notification Not Working**: Verify permissions
3. **Theme Not Applying**: Clear app data and restart
4. **Persian Text Issues**: Ensure proper font loading

### Debug Strategies
- Use Flutter Inspector for UI issues
- Add logging for date operations
- Test on multiple devices
- Profile performance regularly

### Performance Issues
- Monitor memory usage
- Optimize image assets
- Reduce widget rebuilds
- Use const constructors

## Deployment

### Android
- Target SDK 34+
- Minimum SDK 21
- ProGuard optimization
- App bundle format

### iOS
- iOS 12.0+ support
- App Store guidelines compliance
- Privacy manifest
- Bitcode disabled

## Conclusion

This Persian Calendar app represents a comprehensive solution for Persian date management with modern UI/UX, extensive features, and robust architecture. The codebase is maintainable, scalable, and follows Flutter best practices while providing an exceptional user experience for Persian calendar users.