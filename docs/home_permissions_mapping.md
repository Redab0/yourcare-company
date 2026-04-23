# Home Services Permission Mapping (Review Draft)

This document cross-checks current Home visibility rules against the new backend permissions list.

Status: draft mapping for review only. No UI gating changes are implemented from this file yet.

## Current Checks in Code

- Home service cards: `lib/features/screens/home/home_screen.dart` (lines 145-195)
- Bottom nav Requests tab: `lib/features/screens/home/main_layout.dart` (lines 54-64)

## Mapping Table

| UI surface | Navigation target | Current visibility check | Proposed visibility check (new list) | Notes |
|---|---|---|---|---|
| Upcoming Jobs card | `jobs-main-screen` | `Permission.requestsRead` | `Permission.companyRequestsRead` | Jobs appear company-assigned; aligns with `company_requests:read`. |
| Cleaning Requests card | `requests-main-screen` | `Permission.requestsRead` | `Permission.availableRequestsRead` | This looks like browse/assignment flow; aligns with `available_requests:read`. |
| Employee Availability (under House Keeping Configuration) | `employee-availability-screen` | Indirectly visible via always-visible parent card | `Permission.cleanerAvailabilityRead` | Gate this service entry by cleaner availability read permission. |
| HouseKeepingPricing (under House Keeping Configuration) | `housekeeping-configuration-screen` | Indirectly visible via always-visible parent card | `Permission.housekeepingPricingRead` | Gate this service entry by housekeeping pricing read permission. |
| Auto Bidding card | `auto-bidding-screen` | Always visible (no permission check) | `Permission.autoBidRead` | Should be permission-gated if access is role-based. |
| Staff Management card | `staff-main-screen` | `Permission.usersRead` | `Permission.staffRead` | New permissions now use `staff:*` for staff domain. |
| Company Profile card | `business-profile-screen` | `Permission.businessCreate` | `Permission.companyProfileRead` | Current check is create-based; read is more appropriate for visibility. |
| Reports card | `statisticsScreen` | `Permission.transactionsRead` | `Permission.reportsRead` | Dedicated reporting permission exists in new list. |
| Bottom-nav Requests tab | `/requests` | `Permission.requestsRead` | `Permission.availableRequestsRead` OR `Permission.companyRequestsRead` | Suggested logic: show if either available requests or company requests are readable. |
 
## Suggested Show/Hide Logic (Pseudo)

```dart
// showUpcomingJobs = has(companyRequestsRead);
// showCleaningRequests = has(availableRequestsRead);
// showEmployeeAvailability = has(cleanerAvailabilityRead);
// showHouseKeepingPricing = has(housekeepingPricingRead);
// showAutoBid = has(autoBidRead);
// showStaffManagement = has(staffRead);
// showCompanyProfile = has(companyProfileRead);
// showReports = has(reportsRead);
// showRequestsBottomTab = has(availableRequestsRead) || has(companyRequestsRead);
```

## Open Validation Points

- Confirm whether `requests-main-screen` is strictly "available requests" or mixed with company-assigned requests.
- Confirm whether configuration screens should require `read` only for visibility, and `create/update/delete` only for actions inside those screens.
