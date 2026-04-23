# Permissions & API Endpoints Mapping

> Generated: 2026-03-11

---

## Table of Contents

1. [business Resource](#business-resource)
2. [company_profile Resource](#company_profile-resource)
3. [users Resource](#users-resource)
4. [staff Resource](#staff-resource)
5. [requests Resource](#requests-resource)
6. [reports Resource](#reports-resource)
7. [transactions Resource](#transactions-resource)
8. [categories Resource](#categories-resource)
9. [areas Resource](#areas-resource)
10. [teams Resource](#teams-resource)
11. [permissions Resource](#permissions-resource)
12. [housekeeping_pricing Resource](#housekeeping_pricing-resource)
13. [cleaner_availability Resource](#cleaner_availability-resource)
14. [auto_bid Resource](#auto_bid-resource)
15. [Unused Permissions](#unused-permissions)
16. [Duplicate Permissions](#duplicate-permissions)
17. [Endpoints Without Permission Guards](#endpoints-without-permission-guards)

---

## business Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `business:read` | read | GET | `/admin/business` | admin | List businesses (admin only) |
| `business:read` | read | GET | `/admin/business/:id` | admin | Get a business by id (admin only) |
| `business:read` | read | GET | `/business/` | business | Get all businesses |
| `business:read` | read | GET | `/business/:id` | business | Get business by ID |
| `business:create` | create | POST | `/admin/business` | admin | Create business (admin only) |
| `business:create` | create | POST | `/business/` | business | Create business |
| `business:update` | update | PATCH | `/admin/business/:id` | admin | Update business (admin only) |
| `business:update` | update | PATCH | `/business/:id` | business | Update business by ID |
| `business:update` | update | PATCH | `/business/:id/fee` | business | Set fee percentage for a service type |
| `business:update` | update | POST | `/business/my-business/assign-areas` | business | Assign areas to my business |
| `business:update` | update | POST | `/business/:id/assign-areas` | business | Assign areas to business |
| `business:delete` | delete | DELETE | `/business/:id` | business | Delete business by ID |

---

## company_profile Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `company_profile:read` | read | GET | `/business/my-business` | business | Get my business |
| `company_profile:update` | update | PATCH | `/business/my-business` | business | Update my business |

---

## users Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `users:read` | read | GET | `/users/` | users | Get all users |
| `users:read` | read | GET | `/users/customers` | users | Get all customers |
| `users:read` | read | GET | `/admin/customers` | admin | List customers (admin only) |
| `users:read` | read | GET | `/admin/customers/:id` | admin | Get a customer by id (admin only) |
| `users:read` | read | GET | `/admin/admins` | admin | List admin users |
| `users:read` | read | GET | `/admin/business/:id/users` | admin | Get users in a specific business (admin only) |
| `users:create` | create | POST | `/users/` | users | Create user |
| `users:create` | create | POST | `/admin/users` | admin | Create user (admin only) |
| `users:create` | create | POST | `/admin/admins` | admin | Create admin user |
| `users:update` | update | PATCH | `/users/:id/assign-business` | users | Assign user to a business |
| `users:update` | update | PATCH | `/users/:id/remove-business` | users | Remove user from business |
| `users:update` | update | PATCH | `/admin/users/:id` | admin | Update user (admin only) |
| `users:update` | update | POST | `/admin/users/:id/assign-business` | admin | Assign user to a business (admin only) |

---

## staff Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `staff:read` | read | GET | `/business-company/users` | business-company | Get all users assigned to current business |
| `staff:read` | read | GET | `/business-company/users-by-role` | business-company | Get users by role within current business |
| `staff:read` | read | GET | `/business-company/users-with-request-counts` | business-company | Get users with request counts |
| `staff:create` | create | POST | `/business-company/users` | business-company | Create a new user and assign to current business |
| `staff:update` | update | PATCH | `/business-company/users/:id` | business-company | Update another user profile in the business |

---

## requests Resource

> **Note:** Permissions `requests:read`, `company_requests:read`, `company_requests:statistics`, `available_requests:read`, and `available_requests_browse` are all functionally identical (same resource + action). Similarly `requests:update` and `company_requests:update` are identical.

### Read Endpoints

| Permission(s) | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|
| Any `requests:read` | GET | `/requests/` | requests | Get all requests |
| Any `requests:read` | GET | `/requests/available` | requests | Get available requests |
| Any `requests:read` | GET | `/requests/deep-cleaning/business-opportunities` | requests | Business fetches available deep cleaning requests |
| Any `requests:read` | GET | `/requests/deep-cleaning/admin-overview` | requests | Admin fetches all deep cleaning requests |
| Any `requests:read` | GET | `/requests/upholstery-cleaning/business-opportunities` | requests | Business fetches available upholstery cleaning requests |
| Any `requests:read` | GET | `/requests/upholstery-cleaning/admin-overview` | requests | Admin fetches all upholstery cleaning requests |
| Any `requests:read` | GET | `/admin/requests/deep-cleaning` | admin | Fetch all deep-cleaning requests (admin only) |
| Any `requests:read` | GET | `/admin/requests/all` | admin | Fetch all requests (admin only) |
| Any `requests:read` | GET | `/company/requests/` | company | Company fetches assigned requests |
| Any `requests:read` | GET | `/company/requests/reorders` | company | Company fetches reorder requests |
| Any `requests:read` | GET | `/company/requests/calendar` | company | Get calendar view of company works |
| Any `requests:read` | GET | `/company/requests/:id` | company | Get company request by ID |
| Any `requests:read` | GET | `/reorders/company` | reorders | List company reorders |

### Update Endpoints

| Permission(s) | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|
| Any `requests:update` | PATCH | `/requests/:id` | requests | Update request details |
| Any `requests:update` | PATCH | `/requests/:id/frequency-status` | requests | Update frequency status |
| Any `requests:update` | PATCH | `/requests/:id/house-cleaning/accept` | requests | Accept house cleaning request |
| Any `requests:update` | PATCH | `/requests/:id/in-progress` | requests | Set request to in progress |
| Any `requests:update` | PATCH | `/requests/:id/completed` | requests | Complete an in-progress request |
| Any `requests:update` | PATCH | `/admin/requests/:id` | admin | Update a request (admin only) |
| Any `requests:update` | PATCH | `/company/requests/:id/assign-cleaners` | company | Assign cleaners to request |
| Any `requests:update` | PATCH | `/company/requests/:id/assign-team` | company | Assign team to request |
| Any `requests:update` | PATCH | `/company/requests/:id` | company | Update request details |
| Any `requests:update` | PATCH | `/reorders/:id/accept` | reorders | Accept a reorder |

### Delete Endpoints

| Permission | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|
| `requests:delete` | DELETE | `/requests/:id` | requests | Delete request |

---

## reports Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `reports:read` | read | GET | `/admin/reports/requests-statistics` | admin | Global requests statistics |
| `reports:read` | read | GET | `/admin/reports/transactions-statistics` | admin | Global transactions statistics |
| `reports:read` | read | GET | `/admin/reports/businesses-stats` | admin | Statistics grouped by business |
| `reports:read` | read | GET | `/admin/reports/users-stats` | admin | Users statistics by role and totals |
| `reports:read` | read | GET | `/company/requests/reports/statistics` | company | Company statistics with period aggregation |

---

## transactions Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `transactions:read` | read | GET | `/transactions/` | transactions | Get all transactions |
| `transactions:read` | read | GET | `/transactions/my-transactions` | transactions | Get current user transactions |
| `transactions:read` | read | GET | `/admin/transactions` | admin | Fetch transactions (admin only) |
| `transactions:create` | create | POST | `/transactions/` | transactions | Create a new transaction |

---

## categories Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `categories:update` | update | PATCH | `/business-categories/deep-cleaning` | business-categories | Update deep cleaning config |
| `categories:update` | update | PATCH | `/business-categories/house-cleaning` | business-categories | Update house cleaning config |
| `categories:update` | update | PATCH | `/business-categories/upholstery-cleaning` | business-categories | Update upholstery cleaning config |

---

## areas Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `areas:create` | create | POST | `/areas/` | areas | Create a new area |
| `areas:update` | update | PATCH | `/areas/:id` | areas | Update area by ID |
| `areas:delete` | delete | DELETE | `/areas/:id` | areas | Delete area by ID |

---

## teams Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `teams:read` | read | GET | `/teams/business/:businessId` | teams | Get teams by business |
| `teams:read` | read | GET | `/teams/my-company` | teams | Get my company's teams |
| `teams:create` | create | POST | `/teams/` | teams | Create a team |
| `teams:update` | update | PATCH | `/teams/:id` | teams | Update a team |

---

## permissions Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `permissions:read` | read | GET | `/permissions/` | permissions | Get all permissions |
| `permissions:read` | read | GET | `/permissions/:id` | permissions | Get permission by ID |
| `permissions:read` | read | GET | `/permissions/user/:userId` | permissions | Get permissions for a specific user |
| `permissions:create` | create | GET | `/permissions/seed` | permissions | Manually seed permissions |
| `permissions:create` | create | POST | `/permissions/` | permissions | Create a new permission |
| `permissions:update` | update | POST | `/permissions/assign` | permissions | Assign permissions to a user |
| `permissions:update` | update | POST | `/permissions/assign-by-names` | permissions | Assign permissions by names |
| `permissions:update` | update | POST | `/permissions/assign-default/:userId` | permissions | Assign default permissions by role |
| `permissions:update` | update | DELETE | `/permissions/user/:userId` | permissions | Remove all permissions from a user |
| `permissions:update` | update | PATCH | `/permissions/:id` | permissions | Update permission |
| `permissions:update` | update | POST | `/admin/admins/:id/permissions` | admin | Assign permissions to an admin |
| `permissions:delete` | delete | DELETE | `/permissions/:id` | permissions | Delete permission |

---

## housekeeping_pricing Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `housekeeping_pricing:read` | read | GET | `/company/housekeeping-pricing/` | company-housekeeping-pricing | Get housekeeping pricing |
| `housekeeping_pricing:read` | read | POST | `/company/housekeeping-pricing/calculate` | company-housekeeping-pricing | Calculate price preview |
| `housekeeping_pricing:create` | create | POST | `/company/housekeeping-pricing/` | company-housekeeping-pricing | Create or update pricing |
| `housekeeping_pricing:update` | update | POST | `/company/housekeeping-pricing/area-fees` | company-housekeeping-pricing | Add or update an area fee |
| `housekeeping_pricing:update` | update | DELETE | `/company/housekeeping-pricing/area-fees/:areaId` | company-housekeeping-pricing | Remove an area fee |

---

## cleaner_availability Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `cleaner_availability:read` | read | GET | `/company/cleaner-availability/` | company-availability | Get cleaner availability slots |
| `cleaner_availability:create` | create | POST | `/company/cleaner-availability/` | company-availability | Add a cleaner availability slot |
| `cleaner_availability:update` | update | PATCH | `/company/cleaner-availability/:id` | company-availability | Update a slot |
| `cleaner_availability:delete` | delete | DELETE | `/company/cleaner-availability/:id` | company-availability | Delete a slot |

---

## auto_bid Resource

| Permission | Action | HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|---|---|
| `auto_bid:read` | read | GET | `/business/auto-bid/config/:serviceType` | auto-bid | Get auto-bid configuration |
| `auto_bid:read` | read | GET | `/business/auto-bid/categories/:serviceType` | auto-bid | Get category data |
| `auto_bid:read` | read | GET | `/business/auto-bid/default-config/:serviceType` | auto-bid | Get default auto-bid config |
| `auto_bid:create` | create | POST | `/business/auto-bid/config` | auto-bid | Create or update auto-bid config |
| `auto_bid:update` | update | PATCH | `/business/auto-bid/toggle` | auto-bid | Toggle auto-bid on/off |

---

## Unused Permissions

These permissions are seeded in the database but **no API endpoint** currently checks for them:

| Permission Name | Resource | Action |
|---|---|---|
| `email:create` | email | create |
| `email:read` | email | read |
| `email:update` | email | update |
| `email:delete` | email | delete |
| `chat:create` | chat | create |
| `chat:read` | chat | read |
| `chat:update` | chat | update |
| `chat:delete` | chat | delete |
| `upload:create` | upload | create |
| `upload:delete` | upload | delete |
| `categories:create` | categories | create |
| `categories:read` | categories | read |
| `categories:delete` | categories | delete |
| `areas:read` | areas | read |
| `transactions:update` | transactions | update |
| `transactions:delete` | transactions | delete |
| `staff:delete` | staff | delete |

---

## Duplicate Permissions

These permissions have **different names** but are **functionally identical** because the guard only checks `resource + action`:

### requests:read duplicates

| Permission Name | Resource | Action |
|---|---|---|
| `requests:read` | requests | read |
| `company_requests:read` | requests | read |
| `company_requests:statistics` | requests | read |
| `available_requests:read` | requests | read |
| `available_requests_browse` | requests | read |

### requests:update duplicates

| Permission Name | Resource | Action |
|---|---|---|
| `requests:update` | requests | update |
| `company_requests:update` | requests | update |

---

## Endpoints Without Permission Guards

These endpoints use **only @Roles** or are **public** (no permission decorator):

### Admin-Only (Roles only)

| HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|
| GET | `/kpis/gmv` | kpis | GMV metrics |
| GET | `/kpis/active-vendors` | kpis | Active Vendors metrics |
| GET | `/kpis/repeat-booking` | kpis | Repeat Booking Percentage |
| GET | `/kpis/cancellation-rate` | kpis | Cancellation Rate |
| GET | `/kpis/response-time` | kpis | Vendor Response Time |
| GET | `/admin/fee-tiers/` | fee-tiers | Get all fee tiers |
| GET | `/admin/fee-tiers/service/:serviceType` | fee-tiers | Get fee tiers for service |
| PUT | `/admin/fee-tiers/` | fee-tiers | Replace fee tiers |
| GET | `/admin/fee-tiers/company/:id` | fee-tiers | Get fee config for company |
| PATCH | `/admin/fee-tiers/company/:id` | fee-tiers | Set custom fee tiers |
| DELETE | `/admin/fee-tiers/company/:id` | fee-tiers | Reset company fee tiers |
| GET | `/admin/settlements/` | settlements-admin | List all settlements |
| PATCH | `/admin/settlements/:id/approve` | settlements-admin | Approve settlement |
| PATCH | `/admin/settlements/:id/reject` | settlements-admin | Reject settlement |

### Customer-Only (Roles only)

| HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|
| GET | `/requests/deep-cleaning/customer-requests` | requests | Customer deep cleaning requests |
| GET | `/requests/upholstery-cleaning/customer-requests` | requests | Customer upholstery requests |
| GET | `/customer/kpis/statistics` | customer-kpis | My booking statistics |
| GET | `/customer/kpis/favorite-vendors` | customer-kpis | My favorite vendors |
| GET | `/customer/kpis/booking-history` | customer-kpis | My booking history |

### Business-Only (Roles only)

| HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|
| GET | `/settlements/my` | settlements | My settlement requests |
| POST | `/settlements/request` | settlements | Create settlement request |
| GET | `/settlements/summary/my` | settlements | My balance summary |

### Discounts (Admin Roles only)

| HTTP Method | API Endpoint | Controller | Description |
|---|---|---|---|
| POST | `/discounts/` | discounts | Create discount code |
| POST | `/discounts/generate` | discounts | Generate bulk codes |
| GET | `/discounts/` | discounts | Get all discount codes |
| GET | `/discounts/:id` | discounts | Get discount by ID |
| PATCH | `/discounts/:id` | discounts | Update discount code |
| DELETE | `/discounts/:id` | discounts | Delete discount code |
