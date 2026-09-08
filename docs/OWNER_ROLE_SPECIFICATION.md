# Owner Role — Mobile Architecture, Screen Specification & API Mapping

This document provides the complete, authoritative specification for the **Property Owner Role** in the **PG Finder Mobile Application (Flutter)** and its direct mapping to the **Spring Boot Backend APIs**.

---

## 1. Executive Overview & Role Boundary

### 1.1 Owner Persona & Responsibilities
A **Property Owner** (PG Manager / Landlord) manages PG properties, inventory rooms & beds, tenant occupancies, and day-to-day operations:
1. **Property & Inventory Management**: Listing new PG properties with GPS coordinates, house rules, meal plans, and amenities; creating floors and rooms with automated bed generation (`101-A`, `101-B`); and manually toggling bed availability (`VACANT`, `OCCUPIED`, `MAINTENANCE`).
2. **Operations & Tenant Servicing**: Reviewing and resolving tenant maintenance tickets (`OPEN` ➔ `IN_PROGRESS` ➔ `RESOLVED` ➔ `CLOSED`), tracking property occupancy percentages, and auditing tenant rent payment collection per property.

### 1.2 Access & Visibility Isolation
- **Owner Scope**: Full CRUD authority over properties, rooms, beds, and images **owned by the authenticated user**.
- **Owner Isolation**: Strictly isolated by `owner_id = userPrincipal.id`. Owners **cannot** view or modify other owners' properties, rooms, complaints, or financial invoices.
- **Role Guarding**: Protected under `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")`.

---

## 2. Screen-by-Screen UI & Component Specification

```
                          ┌─────────────────────────────────────────┐
                          │               OWNER APP                 │
                          └────────────────────┬────────────────────┘
                                               │
            ┌──────────────────────────────────┴──────────────────────────────────┐
            ▼                                                                     ▼
┌───────────────────────┐                                             ┌───────────────────────┐
│   INVENTORY & PGs     │                                             │ OPERATIONS & REVENUE  │
└───────────┬───────────┘                                             └───────────┬───────────┘
            │                                                                     │
            ├─► Screen O1: Owner Dashboard & KPIs (OwnerDashboardScreen)         ├─► Screen O5: Bed Status Switcher (BedStatusSheet)
            ├─► Screen O2: My Properties List (MyPropertiesTab)                  ├─► Screen O6: Maintenance Resolver (OwnerComplaintsTab)
            ├─► Screen O3: Add/Edit PG Property (AddPropertyScreen)              └─► Screen O7: Property Revenue (PropertyInvoicesScreen)
            └─► Screen O4: Room & Auto-Bed Creator (AddRoomScreen)
```

---

### Screen O1: Owner Command Center & KPI Hub (`OwnerDashboardScreen`)

- **Route**: `/owner-dashboard`
- **Purpose**: High-level operational overview, quick inventory metrics, and primary tab switcher.
- **UI Components & Layout**:
  1. **Top App Bar**: Owner Profile Avatar, Business Name / Full Name, Notification bell (ticket alerts), and Logout button.
  2. **Real-time KPI Metric Carousel**:
     - **Total PGs**: Count of active listings.
     - **Total Beds / Capacity**: (e.g. `24 Total Beds`).
     - **Occupancy Rate**: (e.g. `83% Occupied • 20/24`).
     - **Vacant Beds**: Highlighted green card (e.g. `🟢 4 Vacant Beds`).
     - **Open Maintenance Tickets**: Highlighted amber/red badge (e.g. `⚠️ 2 Pending Tickets`).
  3. **Segmented Navigation Tabs**:
     - **Tab 1: My Properties** (Default active view).
     - **Tab 2: Maintenance Tickets** (Tenant complaints inbox).
  4. **Floating Action Button**: Primary gradient FAB `+ Add New PG` (Navigates to `AddPropertyScreen`).
- **BLoC Binding**: `OwnerBloc` ➔ `LoadOwnerPropertiesRequested()`.

---

### Screen O2: My Properties List Tab

- **Trigger**: Tab 1 in `OwnerDashboardScreen`.
- **Purpose**: Manage existing PG portfolio, view vacancy breakdowns, and launch room additions.
- **UI Components & Layout**:
  1. **Pull-to-Refresh Indicator**: `RefreshIndicator` triggering fresh `LoadOwnerPropertiesRequested()`.
  2. **Property Card Feed**:
     - **Cover Image & Badges**:
       - Verification status badge (`Verified` / `Pending Review`).
       - PG Type badge (`Boys PG` / `Girls PG` / `Co-Ed`).
     - **Header Details**: Title, Full Address, City.
     - **Inventory Badge Row**:
       - `🚪 X Rooms`
       - `🛏️ Y Total Beds`
       - `🟢 Z Available Beds`
     - **Operational Tags**:
       - `⏰ Gate Closes: HH:mm`
       - `🍽️ Food Type: Veg / Non-Veg`
     - **Quick Action Bar**:
       - `[+ Add Room]` (Navigates to `AddRoomScreen` with `propertyId`).
       - `[Manage Beds]` (Opens Bed Status Switcher view).
       - `[View Property]` (Opens public detail preview).
       - `[Edit Details]` (Opens property edit form).
  3. **Empty State**: Friendly illustration "No PGs Listed Yet" with "+ Create First Listing" button.
- **BLoC Binding**: `OwnerBloc` ➔ `LoadOwnerPropertiesRequested()`.

---

### Screen O3: Add / Edit PG Property Screen (`AddPropertyScreen`)

- **Route**: `/owner/add-property`
- **Purpose**: Multi-step or grouped form for creating a new PG listing with GIS coordinates, house policies, meal plans, and amenities.
- **UI Components & Layout**:
  1. **Section 1: General Information**:
     - PG Title (e.g. "Comfort Stay Boys PG").
     - Description (Facilities, atmosphere, nearby transit/colleges).
     - Property Gender Type Selector: `PG_BOYS`, `PG_GIRLS`, `CO_ED`.
  2. **Section 2: Address & Geolocation (GPS)**:
     - Address Line 1 (Street, Sector, Plot No).
     - City (e.g. "New Delhi").
     - State (e.g. "Delhi").
     - Pincode (6-digit numeric input).
     - **GPS Pin Locator**:
       - Latitude & Longitude inputs (e.g. `28.5921`, `77.0460`).
       - "Use Current Device Location" button (populates via `geolocator`).
  3. **Section 3: Rules & Meal Specifications**:
     - Notice Period in Days (e.g. `30` days).
     - Gate Closing Time Picker (TimePicker returning `HH:mm:ss`, e.g. `22:30:00`).
     - Food Provided Toggle: Switch `true/false`.
     - Food Type Selector: `VEG_ONLY`, `NON_VEG_ALLOWED`, `VEG_AND_NON_VEG`, `NO_FOOD`.
  4. **Section 4: Amenities Multi-Select**:
     - Dynamic checkable grid fetching master list from `GET /api/v1/amenities`.
     - Amenities: Wi-Fi (ID: 1), AC (ID: 2), Attached Washroom (ID: 3), Power Backup (ID: 4), Food (ID: 5), Housekeeping (ID: 6), Washing Machine (ID: 7), CCTV (ID: 8), Gym (ID: 9), RO Water (ID: 10).
  5. **Submit Action Button**: "Publish PG Listing" (Triggers `POST /api/v1/properties`).
- **BLoC Binding**: `OwnerBloc` ➔ `CreatePropertyRequested(CreatePropertyDto dto)`.

---

### Screen O4: Room & Auto-Bed Generator Screen (`AddRoomScreen`)

- **Route**: `/owner/properties/:id/add-room`
- **Purpose**: Creates a room and automatically provisions individual bed inventory entities based on room sharing type.
- **UI Components & Layout**:
  1. **Property Header Card**: Shows Property Title and ID.
  2. **Room Number & Floor**:
     - Room Number field (e.g. `101`, `204`, `A-12`).
     - Floor Number picker (e.g. `1`, `2`, `3`).
  3. **Sharing Type & Automated Bed Calculation**:
     - Sharing Type Selector:
       - `SINGLE` ➔ Provisions 1 Bed (`101-A`)
       - `DOUBLE` ➔ Provisions 2 Beds (`101-A`, `101-B`)
       - `TRIPLE` ➔ Provisions 3 Beds (`101-A`, `101-B`, `101-C`)
       - `FOUR_SHARING` ➔ Provisions 4 Beds (`101-A`, `101-B`, `101-C`, `101-D`)
     - **Live Bed Preview Chips**: Visual chips displaying the exact bed codes to be generated.
  4. **Financials**:
     - Monthly Rent per Bed (e.g. `₹8,500.00`).
     - Security Deposit per Bed (e.g. `₹8,500.00`).
  5. **Room Features**:
     - AC Available: Switch toggle.
     - Attached Washroom: Switch toggle.
     - Balcony: Switch toggle.
  6. **Submit Button**: "Save Room & Beds" (Calls `POST /api/v1/properties/{propertyId}/rooms`).
- **BLoC Binding**: `OwnerBloc` ➔ `CreateRoomRequested(propertyId, CreateRoomDto dto)`.

---

### Screen O5: Bed Inventory & Availability Switcher (`ManageRoomsScreen` / `BedStatusSheet`)

- **Route**: `/owner/properties/:id/beds`
- **Purpose**: Real-time room and bed availability viewer with one-tap status toggling.
- **UI Components & Layout**:
  1. **Room Expansion Cards**:
     - Room header with rent, sharing type, and occupancy count (e.g. `Room 101 (Double) • 1/2 Occupied`).
     - **Bed Tile Matrix**:
       - `Bed 101-A` [🟢 `VACANT`]
       - `Bed 101-B` [🔵 `OCCUPIED`]
       - `Bed 101-C` [🟠 `MAINTENANCE`]
  2. **Quick Status Switcher Modal**:
     - Triggered on tapping any bed tile.
     - Radio selector:
       - `🟢 VACANT` (Make available for online search & booking)
       - `🔵 OCCUPIED` (Mark as taken by offline tenant)
       - `🟠 UNDER_MAINTENANCE` (Temporarily lock for painting/repairs)
     - Confirm button (Calls `PATCH /api/v1/beds/{bedId}/status`).
- **BLoC Binding**: `OwnerBloc` ➔ `UpdateBedStatusRequested(bedId, newStatus)`.

---

### Screen O6: Owner Maintenance Ticket Resolver Tab

- **Trigger**: Tab 2 in `OwnerDashboardScreen`.
- **Purpose**: Operational ticket inbox for handling tenant maintenance issues across all owned properties.
- **UI Components & Layout**:
  1. **Filter by Status**: Chips for `ALL`, `OPEN`, `IN_PROGRESS`, `RESOLVED`, `CLOSED`.
  2. **Ticket Card List**:
     - **Header**: Property Name & Room/Bed identifier (e.g. `Comfort Stay Boys PG • Room 102 - Bed B`).
     - **Tenant Name & Contact**: Tenant display name and phone dial shortcut.
     - **Category Tag**: Icon & text (`🚰 PLUMBING`, `⚡ ELECTRICAL`, `📶 WIFI`, `🧹 CLEANING`).
     - **Issue Description**: Tenant's submitted complaint notes and timestamp.
     - **Current Status Badge**:
       - `OPEN` (Red)
       - `IN_PROGRESS` (Amber)
       - `RESOLVED` (Green)
       - `CLOSED` (Gray)
  3. **Resolution Action Modal**:
     - Tap on "Update Status" button opens bottom sheet:
     - New Status Dropdown: `IN_PROGRESS`, `RESOLVED`, `CLOSED`.
     - Resolution Remarks input (e.g., "Plumber visited and replaced kitchen tap washer.").
     - Submit Action (Calls `PATCH /api/v1/complaints/{id}/status`).
- **BLoC Binding**: `OwnerBloc` ➔ `LoadOwnerComplaintsRequested()`, `UpdateComplaintStatusRequested(complaintId, status, notes)`.

---

### Screen O7: Property Invoicing & Revenue Ledger (`PropertyInvoicesScreen`)

- **Route**: `/owner/properties/:id/invoices`
- **Purpose**: Financial tracking of monthly rent collections for a specific PG property.
- **UI Components & Layout**:
  1. **Financial Summary Cards**:
     - Total Invoiced Amount (`₹`).
     - Total Collected / Settled Rent (`₹`).
     - Pending / Overdue Rent (`₹`).
  2. **Tenant Invoices List**:
     - Tenant Name, Bed Code, Billing Month.
     - Invoice Amount, Due Date.
     - Payment Status: `PAID` (with settlement timestamp and payment reference ID) vs `PENDING` vs `OVERDUE`.
- **BLoC Binding**: `OwnerBloc` ➔ `LoadPropertyInvoicesRequested(propertyId)`.

---

## 3. Backend REST API Mapping Catalog (Owner Role)

| Feature Area | HTTP Method | Endpoint Path | Spring Security / PreAuthorize | Request Payload DTO | Response Payload DTO | Status Codes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Owner Properties** | `GET` | `/api/v1/properties/my-properties` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | N/A | `ApiResponse<List<PropertySummaryResponse>>` | `200 OK`, `401 Unauthorized` |
| **Create PG Listing** | `POST` | `/api/v1/properties` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | `CreatePropertyRequest` (`title`, `propertyType`, `addressLine`, `city`, `latitude`, `longitude`, `gateClosingTime`, `foodAvailable`, `foodType`, `amenityIds`) | `ApiResponse<PropertyDetailResponse>` | `201 Created`, `400 Bad Request` |
| **Update PG Details** | `PUT` | `/api/v1/properties/{id}` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | `UpdatePropertyRequest` | `ApiResponse<PropertyDetailResponse>` | `200 OK`, `403 Forbidden` |
| **Delete PG Listing** | `DELETE`| `/api/v1/properties/{id}` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | N/A | `ApiResponse<Void>` | `200 OK`, `403 Forbidden` |
| **Attach PG Images** | `POST` | `/api/v1/properties/{id}/images` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | `AddPropertyImageRequest` (`imageUrl`, `imageTag`, `isCoverImage`) | `ApiResponse<PropertyImageResponse>` | `201 Created`, `400 Bad Request` |
| **Create Room & Beds**| `POST` | `/api/v1/properties/{propertyId}/rooms` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | `CreateRoomRequest` (`roomNumber`, `floorNumber`, `sharingType`, `monthlyRent`, `securityDeposit`, `hasAc`, `hasAttachedWashroom`, `hasBalcony`) | `ApiResponse<RoomResponse>` | `201 Created`, `400 Bad Request` |
| **Update Room** | `PUT` | `/api/v1/rooms/{roomId}` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | `UpdateRoomRequest` | `ApiResponse<RoomResponse>` | `200 OK`, `403 Forbidden` |
| **Toggle Bed Status** | `PATCH` | `/api/v1/beds/{bedId}/status` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | `UpdateBedStatusRequest` (`status` = `VACANT`/`OCCUPIED`/`MAINTENANCE`) | `ApiResponse<BedResponse>` | `200 OK`, `400 Bad Request` |
| **Get Owner Tickets** | `GET` | `/api/v1/complaints/owner` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | N/A | `ApiResponse<List<ComplaintResponse>>` | `200 OK`, `401 Unauthorized` |
| **Update Ticket** | `PATCH` | `/api/v1/complaints/{id}/status` | `@PreAuthorize("isAuthenticated()")` | `UpdateComplaintStatusRequest` (`status`, `resolutionNotes`) | `ApiResponse<ComplaintResponse>` | `200 OK`, `400 Bad Request` |
| **Property Invoices** | `GET` | `/api/v1/invoices/property/{propertyId}`| `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | N/A | `ApiResponse<List<InvoiceResponse>>` | `200 OK`, `403 Forbidden` |

---

## 4. State Management (BLoC Events & States)

### 4.1 OwnerBloc
- **Events**:
  - `LoadOwnerPropertiesRequested()`
  - `CreatePropertyRequested(CreatePropertyDto dto)`
  - `UpdatePropertyRequested(int id, UpdatePropertyDto dto)`
  - `DeletePropertyRequested(int id)`
  - `CreateRoomRequested(int propertyId, CreateRoomDto dto)`
  - `UpdateBedStatusRequested(int bedId, String status)`
  - `LoadOwnerComplaintsRequested()`
  - `UpdateComplaintStatusRequested(int id, String status, String? notes)`
  - `LoadPropertyInvoicesRequested(int propertyId)`
- **States**:
  - `OwnerInitial`
  - `OwnerLoading`
  - `OwnerPropertiesLoaded(List<PropertySummaryModel> properties)`
  - `OwnerComplaintsLoaded(List<ComplaintModel> complaints)`
  - `OwnerInvoicesLoaded(List<InvoiceModel> invoices)`
  - `OwnerOperationSuccess(String message)`
  - `OwnerError(String message)`

---

## 5. Mobile Navigation & Guard Rules

```dart
// Route Guard Example for Owner Protected Routes
String? ownerRouteGuard(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;
  final isAuth = authState is AuthSuccess;
  final role = isAuth ? authState.user.role : null;

  final isOwnerPath = state.uri.path.startsWith('/owner');

  if (isOwnerPath) {
    if (!isAuth) return '/login?redirect=${state.uri.path}';
    if (role != 'OWNER' && role != 'ADMIN') return '/discovery';
  }
  return null;
}
```
