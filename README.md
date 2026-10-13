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
3. Run the app:
   - `flutter run`

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


## Kuwait appointment-time contract (2026-10-09)

Appointment response models use `KuwaitScheduleConverter`: timestamps with `Z` or an explicit offset identify an absolute instant; legacy timestamps without an offset identify Kuwait wall time. Models retain UTC instants. Appointment labels project those instants to Kuwait (UTC+3), independent of the device timezone. Calendar date-only keys remain calendar dates.

`kuwaitWallTime` is a display/picker projection, not a new UTC instant; do not serialize it with a `Z` suffix or project it twice. Customer picker/booking values use `kuwaitWallTimeToJson` to retain the selected clock fields. For example, a 1 PM selection is sent as `13:00` Kuwait wall time, stored as `10:00Z`, and displayed as 1 PM in parent orders, recurring visits, company jobs and calendars. Booking buffers and calendar day boundaries use Kuwait's clock, including while the device is in a different timezone.

Regression coverage includes explicit offsets, legacy offsetless timestamps, parent/nested/recurring schedules, multiple statuses, midnight rollover, a device DST transition date, English/Arabic labels, and New York timezone runs. Customer tests exercise the actual reschedule picker; company tests exercise the actual hourly calendar slot.


## Laundry company configuration (2026-10-09)

The Laundry Configuration home entry opens Working Hours and Pricing. Both use `company_profile:read` / `company_profile:update`; business owners bypass those permissions. Working Hours provides a booking-availability switch, weekly pickup windows, and same-day enable/cutoff controls in Kuwait time. Slots support multiple non-overlapping windows per day and `24:00` as an end boundary. An omitted legacy schedule remains unrestricted; an explicit empty list closes every day. The editor preserves failed-save drafts and confirms discarding unsaved changes.

Pricing retains the item/category catalog and adds a minimum order amount (0–100000 KWD, at most three decimal places; zero disables the minimum). Partial settings PATCH requests send only edited fields so one page cannot overwrite changes made to the other. Customers must select enough items to reach the minimum; pickup/delivery fees do not count. Bag orders snapshot the minimum at booking. Invoice drafts may stay below it, but sending requires the items subtotal before fees and discounts to reach the booked minimum. Historical orders without a minimum retain zero.

`laundry_configuration_test.dart` covers serialization, weekly windows, draft failure/recovery, permissions, bilingual navigation and forms, minimum invoice gating, and the frozen order minimum. New settings require the corresponding backend release; deployment remains an explicit user action.


## Laundry invoice loading (2026-10-10)

Loading invoice items keeps the order details visible and allows leaving the screen. Catalog reads have a 30-second total deadline and cancel abandoned GETs; timeouts or failures show an English/Arabic retry notice. The journey prevents overlapping invoice navigation, reuses a successfully loaded catalog, ignores late responses, and retains invoice selections through failed saves and catalog retries. Invoice mutations are never automatically replayed.

Request authentication now rejects keychain/locale preparation failures and limits keychain reads to 10 seconds, so exceptions before network dispatch cannot leave a screen waiting forever. HTTP logging uses one debug-only metadata logger; large catalog bodies, request/response headers and credentials are not logged. Regression coverage is in `laundry_catalog_loading_test.dart` and `session_request_interceptor_test.dart`.
