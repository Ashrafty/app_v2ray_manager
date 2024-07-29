# V2Ray Manager

## Description
V2Ray Manager is a Flutter-based mobile application designed to manage and control V2Ray proxy configurations. It provides a user-friendly interface for connecting to V2Ray servers, managing server configurations, monitoring traffic statistics, and viewing logs.

<img src="https://github.com/Ashrafty/app_v2ray_manager/blob/main/images/Screenshot_20240729_063308.jpg?raw=true" alt="V2Ray Manager Home Screen" />

## Features

### 1. Server Management
Easily add, edit, and delete V2Ray server configurations.

<img src="https://github.com/Ashrafty/app_v2ray_manager/blob/main/images/Screenshot_20240729_063338.jpg?raw=true" alt="Server Management Screen" />

### 2. Connection Control
Connect and disconnect from V2Ray servers with a single tap.

<img src="https://github.com/Ashrafty/app_v2ray_manager/blob/main/images/Screenshot_20240729_063308.jpg?raw=true" alt="Connection Control Interface" />

### 3. Real-time Traffic Statistics
Monitor your network usage with intuitive charts and graphs.

<img src="https://github.com/Ashrafty/app_v2ray_manager/blob/main/images/Screenshot_20240729_063349.jpg?raw=true" alt="Traffic Statistics Screen" />

### 4. Log Viewer
View detailed connection logs for troubleshooting and monitoring.

<img src="https://github.com/Ashrafty/app_v2ray_manager/blob/main/images/Screenshot_20240729_063401.jpg?raw=true" alt="Log Viewer Screen" />

### 5. Custom Settings
Customize app behavior with settings like bypass LAN and app-specific routing.

<img src="https://github.com/Ashrafty/app_v2ray_manager/blob/main/images/Screenshot_20240729_063416.jpg?raw=true" alt="Settings Screen" />

### 6. Dark Mode
Enjoy a comfortable viewing experience with built-in dark mode support.

<img src="https://github.com/Ashrafty/app_v2ray_manager/blob/main/images/Screenshot_20240729_063749.jpg?raw=true" alt="Side Navigation" />

## Technologies Used
- Flutter: Cross-platform UI framework
- Provider: State management
- flutter_v2ray: V2Ray core implementation for Flutter
- fl_chart: Charting library for traffic statistics
- shared_preferences: Local storage for app settings
- Google Fonts: Custom font integration

## Project Structure
```
lib/
├── models/
│   ├── traffic_stats.dart
│   └── v2ray_config.dart
├── providers/
│   ├── settings_provider.dart
│   ├── theme_provider.dart
│   ├── traffic_stats_provider.dart
│   └── v2ray_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── logs_screen.dart
│   ├── servers_screen.dart
│   ├── settings_screen.dart
│   └── traffic_stats_screen.dart
├── theme/
│   ├── app_theme.dart
│   └── theme_provider.dart
├── utils/
│   ├── constants.dart
│   └── v2ray_helper.dart
├── widgets/
│   ├── bottom_nav_bar.dart
│   ├── side_drawer.dart
│   ├── traffic_chart.dart
│   ├── v2ray_config_card.dart
│   └── v2ray_config_form.dart
├── app.dart
└── main.dart
```

## Main Components and Their Roles

1. **Models**: Define data structures for V2Ray configurations and traffic statistics.
2. **Providers**: Manage the state of the application, including V2Ray connections, settings, and themes.
3. **Screens**: Implement the main UI pages of the application.
4. **Theme**: Define the app's visual style and theme switching functionality.
5. **Utils**: Contain utility functions and constants used throughout the app.
6. **Widgets**: Reusable UI components used across different screens.
7. **app.dart**: Defines the main application structure and routing.
8. **main.dart**: Entry point of the application, sets up providers and runs the app.

## Building and Running the App

### Prerequisites
- Flutter SDK (version 3.19.5)
- Android Studio or VS Code with Flutter extensions
- An Android or iOS device/emulator

### Steps to Run
1. Clone the repository:
   ```
   git clone https://github.com/Ashrafty/app_v2ray_manager.git
   cd app_v2ray_manager
   ```

2. Get the dependencies:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

   This will launch the app on your connected device or emulator.

### Building for Release
To build a release version of the app:

For Android:
```
flutter build apk --release
```

For iOS:
```
flutter build ios --release
```

## Contributing
Contributions to the V2Ray Manager project are welcome. Please feel free to submit issues, fork the repository and send pull requests!

## License
[[MIT](https://github.com/Ashrafty/app_v2ray_manager/blob/main/LICENSE)]

## Disclaimer
This application is for educational purposes only. Ensure you comply with all relevant laws and regulations when using VPN or proxy services.