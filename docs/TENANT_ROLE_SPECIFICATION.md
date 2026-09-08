# Tenant Role — Mobile Architecture, Screen Specification & API Mapping

This document provides the complete, authoritative specification for the **Tenant Role** in the **PG Finder Mobile Application (Flutter)** and its direct mapping to the **Spring Boot Backend APIs**.

---

## 1. Executive Overview & Role Boundary

### 1.1 Tenant Persona & Responsibilities
A **Tenant** (Seeker / Resident) is a primary consumer of the PG Finder platform. The tenant journey consists of two main lifecycle phases:
1. **Discovery & Onboarding (Pre-Booking)**: Finding suitable PG accommodations via geo-spatial search, comparing sharing types, amenities, rules, viewing transparent room & bed availability, and securing a bed with a 15-minute distributed lock & Razorpay advance payment.
2. **Residency & Active Stay (Post-Booking)**: Managing active stay details, viewing and paying monthly rent invoices with instant settlement, logging maintenance complaints (plumbing, Wi-Fi, electrical), tracking ticket resolution in real time, and maintaining verified identity via KYC.

### 1.2 Access & Visibility Isolation
- **Tenant Scope**: Can discover all **verified** PG listings (`is_verified = true`). Can view real-time room and bed availability.
- **Tenant Isolation**: Can **only** access their own bookings, invoices, maintenance complaints, and KYC documents.
- **Role Guarding**: Protected under Spring Security `@PreAuthorize("hasAnyRole('TENANT', 'ADMIN')")` or `isAuthenticated()`. Mobile client enforces GoRouter route guards ensuring non-tenants or unauthenticated users are routed appropriately.

---

## 2. Screen-by-Screen UI & Component Specification

```
                          ┌─────────────────────────────────────────┐
                          │               TENANT APP                │
                          └────────────────────┬────────────────────┘
                                               │
            ┌──────────────────────────────────┴──────────────────────────────────┐
            ▼                                                                     ▼
┌───────────────────────┐                                             ┌───────────────────────┐
│   PRE-BOOKING FLOW    │                                             │   POST-BOOKING FLOW   │
└───────────┬───────────┘                                             └───────────┬───────────┘
            │                                                                     │
            ├─► Screen T1: Discovery & Geo-Search (DiscoveryHomeScreen)          ├─► Screen T6A: Active Stay Hub (ActiveStayTab)
            ├─► Screen T2: Filter Bottom Sheet (FilterBottomSheet)               ├─► Screen T6B: Rent Invoices & Pay (InvoiceListTab)
            ├─► Screen T3: PG Detail & Bed Matrix (PropertyDetailScreen)         ├─► Screen T6C: Maintenance Tickets (ComplaintLoggerTab)
            ├─► Screen T4: 15-Min Lock Checkout (BookingCheckoutSheet)           └─► Screen T7: KYC & Profile (KycUploadScreen)
            └─► Screen T5: Payment & Confirmation (BookingSuccessDialog)
```

---

### Screen T1: Discovery & Geo-Spatial Search Screen (`DiscoveryHomeScreen`)

- **Route**: `/discovery`
- **Purpose**: Main entry landing screen for exploring nearby PG accommodations.
- **UI Components & Layout**:
  1. **Top Search Bar**: Sticky search bar with text input for City/Area/Landmark, Location pin button (autofill current GPS coordinates), and Filter Badge icon with active filter counter.
  2. **Quick Filter Chips**: Horizontal scrollable chips for rapid toggling: `All`, `Boys PG`, `Girls PG`, `Co-Living`, `With Food`, `AC Available`, `< ₹8,000/mo`.
  3. **View Mode Switcher**: Segmented toggle to switch between **List View** and **Interactive Map View**.
  4. **Property Card Feed** (`PropertyCard`):
     - Image carousel with thumbnail badges (`Verified`, `Food Included`, `Boys/Girls`).
     - Property Title (e.g. "Comfort Stay Boys PG").
     - Address line, City & Distance indicator (e.g., `📍 2.4 km away`).
     - Sharing Types Available badges (`Single`, `Double`, `Triple`).
     - Rent Range display: `₹7,500 - ₹12,000 / month`.
     - Live Vacancy Indicator pill: `🟢 4 Beds Available` or `🔴 Fast Filling`.
     - Average Rating and Review count.
  5. **Empty & Loading States**:
     - Skeleton Shimmer loading cards (`LoadingShimmer`).
     - Empty result illustration with "Reset Filters" action button.
- **BLoC Binding**: `DiscoveryBloc` ➔ `FetchPropertiesRequested(criteria)`.

---

### Screen T2: Multi-Criteria Filter Sheet (`FilterBottomSheet`)

- **Trigger**: Filter icon in `DiscoveryHomeScreen`.
- **Purpose**: Fine-grained filtering across geographic radius, budget, room amenities, and meal plans.
- **UI Components & Layout**:
  1. **Geo-Radius Slider**: Range `1.0 km` to `50.0 km` (default: `10.0 km`) with real-time numeric bubble.
  2. **PG Gender Type Radio Chips**: `ALL`, `PG_BOYS`, `PG_GIRLS`, `CO_ED`.
  3. **Room Sharing Type Multi-Select**: `SINGLE`, `DOUBLE`, `TRIPLE`, `FOUR_SHARING`.
  4. **Budget Range Slider**: Dual-thumb range slider `₹3,000` to `₹35,000+`.
  5. **Food Preferences**: `Food Included (Yes/No)`, `VEG_ONLY`, `NON_VEG_ALLOWED`, `VEG_AND_NON_VEG`.
  6. **Amenities Multi-Select Grid**: Wi-Fi, AC, Attached Bathroom, Power Backup, Housekeeping, Washing Machine, RO Purifier, CCTV, Gym, Refrigerator.
  7. **Footer Actions**: "Reset All" text button and "Apply Filters (Show X Results)" filled button.
- **BLoC Binding**: `DiscoveryBloc` ➔ `FilterCriteriaUpdated(criteria)`.

---

### Screen T3: PG Detail & Interactive Room/Bed Matrix (`PropertyDetailScreen`)

- **Route**: `/property/:id`
- **Purpose**: Comprehensive view of property facilities, verified badges, house rules, and room-level bed selection.
- **UI Components & Layout**:
  1. **Hero Media Gallery**: Full-width swipeable image slider with category tag overlays (`COVER`, `BEDROOM`, `WASHROOM`, `COMMON_AREA`).
  2. **Header Info Section**:
     - Verified Green Shield badge (`Platform Verified`).
     - Title, Full Address, and "View on Google Maps" intent link.
     - Owner contact summary (Phone & WhatsApp button).
  3. **House Rules & Schedule Card**:
     - Gate Closing Time (e.g. `⏰ Gate Closes: 22:30`).
     - Notice Period (e.g. `📅 Notice Period: 30 Days`).
     - Food Specification (Meals served, Veg/Non-Veg policy).
  4. **Amenities Grid**: 2-column or 3-column iconography grid of all active amenities.
  5. **Interactive Room & Bed Selection Matrix** (`RoomBedMatrixWidget`):
     - Floor-wise or Sharing-type segmented tabs (`Floor 1`, `Floor 2`, etc.).
     - Room Cards showing: Room Number (e.g. `Room 101`), AC / Attached Washroom tags, Monthly Rent, Security Deposit.
     - **Bed Selector Grid**:
       - `Bed 101-A` [🟢 `VACANT` — Selectable]
       - `Bed 101-B` [🔴 `OCCUPIED` — Disabled / Grayed]
       - `Bed 101-C` [🟡 `RESERVED` — Locked by ongoing checkout]
  6. **Sticky Bottom Action Bar**:
     - Selected Bed Summary: `Bed 101-A | ₹8,500/mo`.
     - "Book Bed Now" Primary CTA button (Navigates to Checkout).
- **BLoC Binding**: `PropertyDetailBloc` ➔ `FetchPropertyDetailRequested(propertyId)`, `SelectBedRequested(bedId)`.

---

### Screen T4: 15-Minute Bed Lock & Booking Checkout (`BookingCheckoutSheet`)

- **Route**: `/checkout`
- **Purpose**: Concurrency-safe bed checkout with distributed lock countdown timer and payment initiation.
- **UI Components & Layout**:
  1. **15-Minute Reservation Countdown Timer Banner**:
     - Amber/Red animated banner: `⏳ Bed locked for: 14:45 minutes. Complete payment to secure.`
     - Auto-cancellation and inventory release on expiry.
  2. **Booking Summary Card**:
     - PG Name & Room/Bed identifier (e.g. `Comfort Stay Boys PG — Room 101, Bed A`).
     - Check-in Date Picker (enforces `@FutureOrPresent` selection).
     - Expected Stay Duration selector (in months).
  3. **Transparent Price Breakdown**:
     - Monthly Rent: `₹8,500.00`
     - Security Deposit: `₹8,500.00`
     - Token Advance Required (10% or Full): `₹1,000.00`
     - Platform Convenience Fee: `₹0.00 (Waived)`
     - **Total Payable Now**: `₹1,000.00`
  4. **Terms & Cancellation Policy Checkbox**: Mandatory checkbox before proceeding.
  5. **CTA Button**: "Proceed to Pay ₹1,000 via Razorpay" (Triggers `POST /api/v1/bookings/initiate`).
- **BLoC Binding**: `BookingBloc` ➔ `InitiateBookingRequested(bedId, checkInDate, tokenAmount)`.

---

### Screen T5: Razorpay Gateway & Booking Confirmation (`BookingSuccessDialog`)

- **Purpose**: Native Razorpay SDK modal integration and immediate HMAC verification.
- **Flow**:
  1. App initializes `Razorpay` Flutter plugin with `orderId`, `key_id`, `amount`, and pre-filled user contact details.
  2. On `PAYMENT_SUCCESS`: App immediately posts `razorpay_payment_id`, `razorpay_order_id`, and `razorpay_signature` to backend `POST /api/v1/payments/verify`.
  3. Backend verifies HMAC SHA-256 signature, commits booking to `CONFIRMED`, and sets bed to `OCCUPIED`.
  4. **Success Dialog**:
     - Lottie confetti animation.
     - Booking Reference ID (e.g. `#BK-2026-0908-01`).
     - Check-in instructions & Owner phone number.
     - "Go to My Active Stay" CTA button.
- **BLoC Binding**: `BookingBloc` ➔ `VerifyPaymentRequested(...)`.

---

### Screen T6: Tenant Dashboard & Resident Portal (`TenantDashboardScreen`)

- **Route**: `/tenant-portal`
- **Purpose**: Centralized hub for tenant living experience, rent payments, and maintenance requests.
- **Tabs**:

#### Tab T6.1: Active Stay (`ActiveStayTab`)
- **UI Elements**:
  - Current PG Banner with Property Photo & Address.
  - Room & Bed Number badge (`Room 101 - Bed A`).
  - Active Stay Duration Counter (e.g. `Checked in on 01 Sep 2026 • 8 days`).
  - Monthly Rent & Next Due Date indicator.
  - Emergency Contacts & PG Manager quick-dial buttons.
  - Wi-Fi SSID & Password card (if available).
  - Gate Closing Countdown clock.

#### Tab T6.2: Rent Invoices & Online Settlement (`InvoiceListTab`)
- **UI Elements**:
  - Unpaid / Overdue Invoices Alert Banner (if any).
  - Invoices List: Grouped by Billing Month (e.g., `September 2026`, `August 2026`).
  - Invoice Card:
    - Status Badge: `PAID` (Green), `PENDING` (Amber), `OVERDUE` (Red).
    - Base Rent + Utility Charges breakdown.
    - Due Date.
    - "Pay Rent Now" Button (for pending/overdue invoices):
      - Triggers `POST /api/v1/invoices/{id}/initiate-payment` (creates Razorpay order).
      - Opens Razorpay SDK.
      - On completion, calls `POST /api/v1/invoices/{id}/pay` and refreshes status to `PAID`.
    - "Download PDF Receipt" icon.

#### Tab T6.3: Maintenance & Complaint Tickets (`ComplaintLoggerTab`)
- **UI Elements**:
  - "+ Raise Maintenance Request" Floating Action Button.
  - Ticket Creation Bottom Sheet:
    - Category Dropdown: `PLUMBING`, `ELECTRICAL`, `WIFI`, `CLEANING`, `APPLIANCE`, `SECURITY`, `OTHER`.
    - Description Text Area (minimum 10 characters).
    - Urgency Level selector (`LOW`, `MEDIUM`, `HIGH`, `EMERGENCY`).
    - Photo Attachment picker (Camera/Gallery).
    - Submit Button (Calls `POST /api/v1/complaints`).
  - Active & Past Tickets List:
    - Ticket Reference Number & Category icon.
    - Visual Step Tracker: `OPEN` ➔ `IN_PROGRESS` ➔ `RESOLVED` ➔ `CLOSED`.
    - Owner Resolution Notes & Timestamp.
- **BLoC Binding**: `TenantPortalBloc` ➔ `FetchActiveStayRequested()`, `FetchTenantInvoicesRequested()`, `FetchTenantComplaintsRequested()`, `CreateComplaintRequested(...)`.

---

### Screen T7: Tenant KYC & Profile Screen (`KycUploadScreen`)

- **Route**: `/kyc-upload`
- **Purpose**: Submitting mandatory identity proof for property onboarding and lease agreements.
- **UI Elements**:
  - Document Type Selector: `AADHAAR`, `PAN`, `PASSPORT`, `DRIVING_LICENSE`.
  - Document Identification Number input field (with regex validation).
  - Front & Back Photo Upload Pickers.
  - Current KYC Status Card:
    - `NOT_SUBMITTED` (Yellow)
    - `PENDING` (Blue — "Under Review by Platform Admin")
    - `VERIFIED` (Green — "Verified Tenant")
    - `REJECTED` (Red — Displays rejection reason with "Re-upload" CTA).
- **BLoC Binding**: `AuthBloc` ➔ `UploadKycRequested(...)`, `FetchKycStatusRequested()`.

---

## 3. Backend REST API Mapping Catalog (Tenant Role)

| Feature Area | HTTP Method | Endpoint Path | Spring Security / PreAuthorize | Request Payload DTO | Response Payload DTO | Status Codes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Geo-Discovery** | `GET` | `/api/v1/properties/search` | Public / Open | `PropertySearchCriteria` (Query params) | `ApiResponse<PageResponse<SearchPropertyResponse>>` | `200 OK`, `400 Bad Request` |
| **Property Details** | `GET` | `/api/v1/properties/{id}` | Public / Open | N/A (Path Variable: `id`) | `ApiResponse<PropertyDetailResponse>` | `200 OK`, `404 Not Found` |
| **Room Inventory** | `GET` | `/api/v1/properties/{id}/rooms`| Public / Open | N/A (Path Variable: `id`) | `ApiResponse<List<RoomResponse>>` | `200 OK`, `404 Not Found` |
| **Initiate Bed Booking**| `POST` | `/api/v1/bookings/initiate` | `@PreAuthorize("hasAnyRole('TENANT', 'ADMIN')")` | `InitiateBookingRequest` (`bedId`, `checkInDate`, `tokenAmount`) | `ApiResponse<BookingResponse>` (Includes Razorpay `orderId`) | `201 Created`, `400 Bad Request`, `409 Conflict` (Bed Taken) |
| **Verify Payment** | `POST` | `/api/v1/payments/verify` | `@PreAuthorize("hasAnyRole('TENANT', 'ADMIN')")` | `VerifyPaymentRequest` (`paymentId`, `orderId`, `signature`, `bookingId`) | `ApiResponse<BookingResponse>` | `200 OK`, `400 Invalid Signature` |
| **My Stays / Bookings**| `GET` | `/api/v1/bookings/my-bookings`| `@PreAuthorize("isAuthenticated()")` | N/A | `ApiResponse<List<BookingResponse>>` | `200 OK`, `401 Unauthorized` |
| **Cancel Reservation** | `POST` | `/api/v1/bookings/{id}/cancel` | `@PreAuthorize("isAuthenticated()")` | `CancelBookingRequest` (`cancellationReason`) | `ApiResponse<BookingResponse>` | `200 OK`, `400 Bad Request` |
| **My Rent Invoices** | `GET` | `/api/v1/invoices/my-invoices`| `@PreAuthorize("isAuthenticated()")` | N/A | `ApiResponse<List<InvoiceResponse>>` | `200 OK`, `401 Unauthorized` |
| **Initiate Rent Pay** | `POST` | `/api/v1/invoices/{id}/initiate-payment` | `@PreAuthorize("hasAnyRole('TENANT', 'ADMIN')")` | N/A (Path Variable: `id`) | `ApiResponse<PaymentOrderResponse>` | `200 OK`, `404 Not Found` |
| **Settle Rent Invoice**| `POST` | `/api/v1/invoices/{id}/pay` | `@PreAuthorize("hasAnyRole('TENANT', 'ADMIN')")` | `PayInvoiceRequest` (`paymentId`, `orderId`, `signature`) | `ApiResponse<InvoiceResponse>` | `200 OK`, `400 Bad Request` |
| **Log Complaint Ticket**| `POST` | `/api/v1/complaints` | `@PreAuthorize("hasAnyRole('TENANT', 'ADMIN')")` | `CreateComplaintRequest` (`propertyId`, `roomId`, `title`, `description`, `category`) | `ApiResponse<ComplaintResponse>` | `201 Created`, `400 Bad Request` |
| **My Complaints** | `GET` | `/api/v1/complaints/my-complaints`| `@PreAuthorize("isAuthenticated()")` | N/A | `ApiResponse<List<ComplaintResponse>>` | `200 OK`, `401 Unauthorized` |
| **Submit KYC** | `POST` | `/api/v1/kyc/upload` | `@PreAuthorize("isAuthenticated()")` | `KycUploadRequest` (`documentType`, `documentNumber`, `documentUrl`) | `ApiResponse<KycDocumentResponse>` | `201 Created`, `400 Bad Request` |
| **My KYC Documents** | `GET` | `/api/v1/kyc/my-documents` | `@PreAuthorize("isAuthenticated()")` | N/A | `ApiResponse<List<KycDocumentResponse>>` | `200 OK`, `401 Unauthorized` |

---

## 4. State Management (BLoC Events & States)

### 4.1 DiscoveryBloc
- **Events**:
  - `FetchPropertiesRequested(PropertySearchCriteria criteria)`
  - `FilterCriteriaUpdated(PropertySearchCriteria criteria)`
  - `ClearFiltersRequested()`
- **States**:
  - `DiscoveryInitial`
  - `DiscoveryLoading`
  - `DiscoveryLoaded(List<PropertySummaryModel> properties, int totalPages, int currentPage)`
  - `DiscoveryError(String message)`

### 4.2 BookingBloc
- **Events**:
  - `InitiateBookingRequested(int bedId, String checkInDate, double tokenAmount)`
  - `VerifyPaymentRequested(String paymentId, String orderId, String signature, int bookingId)`
  - `CancelBookingRequested(int bookingId, String reason)`
  - `LockTimerTicked(int secondsRemaining)`
- **States**:
  - `BookingInitial`
  - `BookingInitiating`
  - `BookingLockAcquired(BookingModel booking, PaymentOrderModel paymentOrder, int lockDurationSeconds)`
  - `PaymentVerificationInProgress`
  - `BookingConfirmed(BookingModel booking)`
  - `BookingLockExpired`
  - `BookingError(String message)`

### 4.3 TenantPortalBloc
- **Events**:
  - `FetchActiveStayRequested()`
  - `FetchTenantInvoicesRequested()`
  - `InitiateInvoicePaymentRequested(int invoiceId)`
  - `PayInvoiceRequested(int invoiceId, String paymentId, String orderId, String signature)`
  - `FetchTenantComplaintsRequested()`
  - `CreateComplaintRequested(CreateComplaintDto dto)`
- **States**:
  - `TenantPortalInitial`
  - `TenantPortalLoading`
  - `ActiveStayLoaded(BookingModel activeStay)`
  - `TenantInvoicesLoaded(List<InvoiceModel> invoices)`
  - `TenantComplaintsLoaded(List<ComplaintModel> complaints)`
  - `InvoicePaymentOrderCreated(PaymentOrderModel order)`
  - `InvoiceSettledSuccessfully(InvoiceModel invoice)`
  - `ComplaintCreatedSuccessfully(ComplaintModel complaint)`
  - `TenantPortalError(String message)`

---

## 5. Mobile Navigation & Guard Rules

```dart
// Route Guard Example for Tenant Protected Routes
String? tenantRouteGuard(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;
  final isAuth = authState is AuthSuccess;
  final role = isAuth ? authState.user.role : null;

  final isTenantOnlyPath = state.uri.path.startsWith('/tenant-portal') ||
                           state.uri.path.startsWith('/checkout');

  if (isTenantOnlyPath) {
    if (!isAuth) return '/login?redirect=${state.uri.path}';
    if (role != 'TENANT' && role != 'ADMIN') return '/discovery';
  }
  return null;
}
```
