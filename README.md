# KW Clean Business Platform

A comprehensive business management platform for cleaning service businesses built with Flutter.

## Features

### Business Management
- **Business Profile Management**: Manage business details, service areas, and contact information
- **Cleaning Request Management**: Handle both deep cleaning (quote-based) and house keeping requests
- **Staff Management**: Manage staff with different roles (owner, manager, worker)
- **Performance Analytics**: View reports and metrics on business performance

### Driver/Worker Features
- Track upcoming and completed jobs
- Manage cleaning crews
- View job details and schedules

## Architecture

The app follows a clean architecture approach with:

- **Domain Layer**: Core business logic and entities
- **Data Layer**: Data sources and repositories
- **Presentation Layer**: BLoC pattern for state management with UI screens

## Technical Details

- **State Management**: BLoC pattern
- **Navigation**: GoRouter for routing
- **Authentication**: JWT-based authentication
- **Role-based Access Control**: Different functionality based on user role

## Demo Mode

This app includes a fully functional demo mode that allows you to explore all features without requiring a backend server:

- **Automatic Authentication**: Any credentials will work in demo mode
- **Pre-defined User Roles**:
  - Business Owner: `demo@kwclean.com` (default)
  - Manager: `faisal.manager@example.com`
  - Worker: `ahmed.driver@example.com`
- **Mock Data**: Comprehensive mock data for:
  - Business profile
  - Cleaning requests (both deep cleaning and house keeping)
  - Staff management
  - Performance reports
  - Crews and workers

To use demo mode:
1. Launch the app
2. On the login screen, you'll see a "Demo Mode Information" card
3. You can use any of the provided accounts to explore different user roles
4. All mock data is pre-loaded and fully interactive

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app in demo mode

## Screenshots

(Screenshots will be added soon)

## User Roles

- **Business Owner**: Full access to all features
  - View all cleaning requests
  - Manage staff and assign roles
  - View performance analytics
  - Create quotes for deep cleaning requests

- **Manager**: Can manage workers, schedules, and accept cleaning requests
  - View assigned cleaning requests
  - Manage workers
  - View limited performance metrics

- **Worker**: Can view assigned jobs and mark them as completed
  - View only assigned jobs
  - Update job status
  - Track work schedule

## License

This project is proprietary and not open for redistribution.