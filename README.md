# Study Planner App

A Flutter-based mobile application for managing study tasks with calendar integration and reminder functionality.

## Features

- **Task Management**: Create, view, and manage study tasks with titles, descriptions, and due dates
- **Today's View**: Dedicated screen showing all tasks due today
- **Calendar Integration**: Monthly calendar view with visual indicators for dates containing tasks
- **Task Reminders**: Set reminder times for tasks with popup notifications
- **Local Storage**: All tasks persist locally using SharedPreferences
- **Clean UI**: Material Design principles with intuitive navigation

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Storage**: SharedPreferences for local data persistence
- **State Management**: StatefulWidget with setState

## Project Structure
lib/
├── main.dart              # App entry point and navigation
├── task.dart              # Task model and data structure
├── storage_service.dart   # Local storage operations
├── today_screen.dart      # Today's tasks view
├── calender_screen.dart   # Calendar and task view by date
├── settings_screen.dart   # App settings and preferences
└── add_task_dialog.dart   # Dialog for creating new tasks
## Installation & Setup

1. Clone the repository
2. Ensure Flutter is installed on your system
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to launch the app on an emulator or device

## Dependencies

- `shared_preferences: ^2.2.2` - Local data storage
- `intl: ^0.19.0` - Date formatting

## How It Works

### Task Storage
Tasks are stored locally using SharedPreferences as JSON strings. The StorageService class handles all save/load operations, ensuring data persists between app sessions.

### Navigation
The app uses a BottomNavigationBar to switch between three main screens: Today, Calendar, and Settings. Each screen is a separate StatefulWidget that manages its own state.

### Reminder System
On app launch, the system checks for tasks with reminder times set for the current day and displays a popup alert if any are found.


## License

MIT License
