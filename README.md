# VisitorGuard - Flutter Mobile Application

A comprehensive visitor management system with role-based access for Security and Employee users.

## Features

### 🔐 Authentication
- Employee ID and Password login
- Biometric login (UI only)
- Role selection after login

### 👮 Security User Features
- QR Code scanner for visitor check-in
- Visitor management with filtering
- Real-time dashboard with statistics
- Notification system for alerts

### 👤 Employee User Features
- Personal visitor dashboard
- Appointment timeline view
- Invite visitor functionality
- Visitor management

### 🔔 Common Features
- Role-based bottom navigation
- Profile management
- Notification system
- Clean, modern UI design

## Tech Stack

- **Framework**: Flutter (latest stable)
- **Language**: Dart (null safety)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Architecture**: Feature-first structure

## Project Structure

```
lib/
├── core/
│   ├── theme/           # App theme configuration
│   ├── widgets/         # Shared widgets
│   └── constants/       # App constants and colors
├── features/
│   ├── auth/           # Authentication screens
│   ├── role/           # Role selection
│   ├── scanner/        # QR scanner (Security)
│   ├── visitors/       # Visitor management
│   ├── dashboard/      # Dashboard screens
│   ├── notifications/  # Notification system
│   └── profile/        # User profile
├── models/             # Data models
├── mock_data/          # Static mock data
├── routes/             # App routing configuration
└── main.dart          # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   cd visitor_guard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Login Credentials (Mock)
- **Employee ID**: Any non-empty string
- **Password**: Any non-empty string

### Role Selection
After login, choose between:
- **Security User**: Access to scanner, visitor management, security dashboard
- **Employee User**: Access to personal dashboard, visitor invitations

## App Flow

1. **Launch** → Login Screen
2. **Login** → Role Selection
3. **Role Selection** → Role-based Dashboard
4. **Navigation** → Bottom tabs (role-dependent)

## Key Screens

### 🔑 Login Screen
- VisitorGuard logo and branding
- Employee ID and password fields
- Form validation
- Biometric login option (UI only)

### 🎭 Role Selection
- Security User card
- Employee User card
- Visual selection feedback

### 📱 QR Scanner (Security)
- Camera preview placeholder
- Scan frame overlay
- Flash toggle
- Mock scan results

### 👥 Visitors Management
- Tabbed interface (Today's/All Visitors)
- Search and filter functionality
- Visitor cards with status badges
- Add walk-in visitor option

### 📊 Dashboard
- **Security**: Statistics cards, recent activity
- **Employee**: Today's appointments, timeline view

### 🔔 Notifications
- Categorized tabs (All/Arrivals/Approvals/Alerts)
- Severity badges
- Unread indicators

### 👤 Profile
- User information display
- App info and support
- Logout functionality

## Design System

### Colors
- **Primary**: Blue (#2196F3)
- **Pending**: Orange (#FF9800)
- **Approved**: Blue (#2196F3)
- **Checked-in**: Green (#4CAF50)
- **Overstay**: Red (#F44336)

### UI Elements
- Card-based layouts
- 12-16px rounded corners
- Consistent spacing and typography
- Status color coding
- Loading and empty states

## Mock Data

The app uses static mock data for:
- User profiles (Security/Employee)
- Visitor lists with various statuses
- Notifications with different types and severities
- No backend integration required

## Development Notes

- **No Camera Integration**: Scanner uses mock functionality
- **No API Calls**: All data is static/mock
- **UI Focus**: Emphasis on pixel-perfect design and smooth UX
- **State Management**: Riverpod for UI state only
- **Navigation**: GoRouter with role-based routing

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Support

For technical support or questions:
- Email: support@visitorguard.com
- Phone: +1 (555) 123-4567

## License

This project is for demonstration purposes only.