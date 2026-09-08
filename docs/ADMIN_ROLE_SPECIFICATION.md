# Admin Role — Mobile Architecture, Screen Specification & API Mapping

This document provides the complete, authoritative specification for the **Platform Administrator Role (Super-Admin)** in the **PG Finder Mobile Application (Flutter)** and its direct mapping to the **Spring Boot Backend APIs**.

---

## 1. Executive Overview & Role Boundary

### 1.1 Admin Persona & Responsibilities
A **Platform Administrator** (Super-Admin / Operations Lead) holds global oversight and governance across all platform operations, ensuring trust, safety, financial automation, and compliance:
1. **Property Quality & Listing Approvals**: Reviewing newly submitted PGs from owners, inspecting house rules, photos, and amenities, and approving or rejecting listings with feedback.
2. **Identity & KYC Verification**: Inspecting government ID documents submitted by tenants and owners, verifying authenticity, and approving or rejecting KYC with detailed audit remarks.
3. **Financial Invoicing Batch Engine**: Triggering and supervising automated monthly rent generation batch jobs across all active platform stays.
4. **Platform Governance & User Management**: Monitoring all complaints, handling dispute escalations, managing user accounts, and monitoring infrastructure health.

### 1.2 Access & Visibility Isolation
- **Admin Scope**: Global access to all properties, rooms, beds, bookings, payments, invoices, complaints, and user accounts.
- **Role Guarding**: Protected under Spring Security `@PreAuthorize("hasRole('ADMIN')")`. Mobile client enforces strict admin-only route guards.

---

## 2. Screen-by-Screen UI & Component Specification

```
                          ┌─────────────────────────────────────────┐
                          │                ADMIN APP                │
                          └────────────────────┬────────────────────┘
                                               │
            ┌──────────────────────────────────┴──────────────────────────────────┐
            ▼                                                                     ▼
┌───────────────────────┐                                             ┌───────────────────────┐
│  GOVERNANCE & QUEUES  │                                             │ AUTOMATION & USERS    │
└───────────┬───────────┘                                             └───────────┬───────────┘
            │                                                                     │
            ├─► Screen A1: Admin Command Center (AdminDashboardScreen)            ├─► Screen A4: Monthly Invoicing Engine (AdminInvoiceBatchScreen)
            ├─► Screen A2: PG Approvals Queue (AdminPendingPropertiesScreen)     ├─► Screen A5: Global Dispute Monitor (AdminComplaintsScreen)
            ├─► Screen A3: KYC Verification Queue (AdminKycVerificationScreen)   ├─► Screen A6: User Directory (AdminUsersScreen)
            │                                                                     └─► Screen A7: System Health (AdminSystemHealthScreen)
```

---

### Screen A1: Admin Command Center & Global KPI Hub (`AdminDashboardScreen`)

- **Route**: `/admin/dashboard`
- **Purpose**: Global platform analytics, approval queue counters, and central navigation hub.
- **UI Components & Layout**:
  1. **Top App Bar**: Admin Shield avatar, "Platform Admin Console", Real-time System Status Indicator (🟢 `All Systems Operational`).
  2. **Global Platform Metrics Grid**:
     - **Active PGs**: Count of live verified properties.
     - **Pending PG Approvals**: Highlighted badge card (e.g. `⏳ 5 PGs Awaiting Review`).
     - **Pending KYC Submissions**: Highlighted badge card (e.g. `📋 12 KYCs Pending`).
     - **Total Active Tenants**: Total confirmed active stay leases.
     - **Monthly Invoicing Status**: Processed count and collection volume for current month (`₹`).
  3. **Operational Action Grid (Navigation Tiles)**:
     - 🏢 **PG Approvals Queue** ➔ Navigates to `AdminPendingPropertiesScreen`.
     - 🆔 **KYC Verification Queue** ➔ Navigates to `AdminKycVerificationScreen`.
     - ⚙️ **Generate Monthly Invoices** ➔ Navigates to `AdminInvoiceBatchScreen`.
     - 🚨 **Global Complaint Monitor** ➔ Navigates to `AdminComplaintsScreen`.
     - 👥 **User Account Directory** ➔ Navigates to `AdminUsersScreen`.
     - 🩺 **System & Redis Health** ➔ Navigates to `AdminSystemHealthScreen`.
- **BLoC Binding**: `AdminDashboardBloc` ➔ `FetchGlobalMetricsRequested()`.

---

### Screen A2: Property Approval & Verification Queue (`AdminPendingPropertiesScreen`)

- **Route**: `/admin/properties/pending`
- **Purpose**: Review submitted PG properties awaiting public discovery approval.
- **UI Components & Layout**:
  1. **Pending Queue Feed**: List of PG cards with status `is_verified = false`.
  2. **Property Review Card**:
     - **Media Preview**: Carousel of uploaded photos with tags (`COVER`, `BEDROOM`, etc.).
     - **Property Info**: Title, Description, Gender Type (`Boys/Girls/Co-Ed`), Address & Coordinates.
     - **Owner Contact Banner**: Owner Full Name, Phone, Email, Owner KYC Status badge.
     - **Rules & Food**: Gate Closing Time, Notice Period, Food Policy.
     - **Amenities Included**: Badges for verified amenities.
     - **Room & Bed Matrix Preview**: Breakdown of rooms and beds configured.
  3. **Verification Action Bar**:
     - **[✅ Approve Listing]**:
       - Triggers confirmation dialog.
       - Calls `PATCH /api/v1/admin/properties/{id}/verify` with `{ "verified": true, "remarks": "Approved after inspection." }`.
       - Property instantly becomes discoverable in public search.
     - **[❌ Reject Listing]**:
       - Opens Rejection Reason Modal (mandatory feedback text, e.g. "Photos unclear and gate time missing").
       - Calls `PATCH /api/v1/admin/properties/{id}/verify` with `{ "verified": false, "remarks": "Reason..." }`.
- **BLoC Binding**: `AdminPropertyBloc` ➔ `FetchPendingPropertiesRequested()`, `VerifyPropertyRequested(id, verified, remarks)`.

---

### Screen A3: Global KYC Verification Queue (`AdminKycVerificationScreen`)

- **Route**: `/admin/kyc/pending`
- **Purpose**: Verify submitted identity documents for tenants and owners.
- **UI Components & Layout**:
  1. **Filter Tabs**: `PENDING REVIEW` (Default), `VERIFIED`, `REJECTED`.
  2. **KYC Document Review Card**:
     - **User Identity**: Full Name, Registered Email, Phone, Role Badge (`TENANT` / `OWNER`).
     - **Document Information**: Document Type (`AADHAAR`, `PAN`, `PASSPORT`, `DRIVING_LICENSE`), Document Identification Number.
     - **Document Image Viewer**:
       - Tap to open high-resolution zoomable viewer (Pinch-to-zoom).
       - Front Image & Back Image tabs.
     - **Submitted Timestamp**: Date & time of upload.
  3. **Verification Actions**:
     - **[Approve Document]**: Calls `PATCH /api/v1/kyc/{id}/verify` with `{ "status": "VERIFIED" }`.
     - **[Reject Document]**: Opens modal requiring rejection reason (e.g. "Aadhaar number does not match image"), calls with `{ "status": "REJECTED", "rejectionReason": "..." }`.
- **BLoC Binding**: `AdminKycBloc` ➔ `FetchPendingKycRequested()`, `VerifyKycDocumentRequested(id, status, rejectionReason)`.

---

### Screen A4: Monthly Invoicing Batch Job Engine (`AdminInvoiceBatchScreen`)

- **Route**: `/admin/invoices/batch`
- **Purpose**: Manually trigger or monitor automated rent invoice generation for all active leases.
- **UI Components & Layout**:
  1. **Invoicing Engine Status Banner**:
     - Invoicing Cycle schedule information (Runs 1st of every month).
     - Active Stays Count eligible for rent billing.
  2. **Billing Month Selector**:
     - Date Picker / Month-Year Selector (defaults to current month: `YYYY-MM-01`).
  3. **Batch Execution Trigger**:
     - Primary Button: "⚡ Generate Invoices for [Selected Month]".
     - Confirmation Dialog with safety summary.
     - Calls `POST /api/v1/invoices/admin/generate-monthly?billingMonth=YYYY-MM-01`.
  4. **Execution Result Summary Card**:
     - Success Banner: `✅ Invoicing Run Completed`.
     - Summary Metrics: `142 Invoices Generated • ₹1,207,000 Total Invoiced Volume`.
     - Skipped / Duplicate Prevention: Ensures idempotency (no duplicate invoices for same tenant & month).
- **BLoC Binding**: `AdminInvoiceBloc` ➔ `TriggerMonthlyInvoicingRequested(billingMonth)`.

---

### Screen A5: Global Maintenance & Dispute Monitor (`AdminComplaintsScreen`)

- **Route**: `/admin/complaints`
- **Purpose**: Platform-wide ticket oversight to ensure owners resolve maintenance within SLA.
- **UI Components & Layout**:
  1. **Filter Bar**: Filter by Property, Status (`OPEN`, `IN_PROGRESS`, `RESOLVED`, `CLOSED`), Category, and Urgency.
  2. **SLA Breach Alert Filter**: Quick filter to highlight tickets unresolved for > 48 hours.
  3. **Ticket Detailed Inspection**:
     - Tenant Details & Room/Bed.
     - Property Name & Owner Details.
     - Full resolution timeline with timestamps.
     - Super-Admin Override button (allows Admin to update status or record notes).
- **BLoC Binding**: `AdminComplaintsBloc` ➔ `FetchAllComplaintsRequested(filter)`.

---

### Screen A6: User Directory & Access Management (`AdminUsersScreen`)

- **Route**: `/admin/users`
- **Purpose**: View registered users, audit KYC statuses, and inspect user activity.
- **UI Components & Layout**:
  1. **Search & Filter Bar**: Search by Name, Email, Phone Number, or Role (`TENANT`, `OWNER`, `ADMIN`).
  2. **User Profile Card**:
     - User ID, Full Name, Avatar.
     - Role Badge with distinct colors (`TENANT` = Blue, `OWNER` = Purple, `ADMIN` = Red).
     - KYC Status Badge (`VERIFIED`, `PENDING`, `NOT_SUBMITTED`).
     - Registration Date & Last Active timestamp.
  3. **User Detail Sheet**:
     - Associated Active Stays (if Tenant).
     - Associated Properties (if Owner).
- **BLoC Binding**: `AdminUserBloc` ➔ `FetchUsersRequested(query, role)`.

---

### Screen A7: System Health & Infrastructure Telemetry (`AdminSystemHealthScreen`)

- **Route**: `/admin/system-health`
- **Purpose**: Live health check of backend services, MySQL database, Redis distributed locking, and storage.
- **UI Components & Layout**:
  - API Health: `UP` (`GET /api/v1/health`).
  - Database: MySQL 8 Spatial SRID 4326 Connectivity (`UP`).
  - Cache & Distributed Locks: Redis 7 (`UP`).
  - Version & Build: `v1.0.0-PROD (Spring Boot 3.3.x, Java 17)`.
- **BLoC Binding**: `AdminSystemHealthBloc` ➔ `FetchHealthRequested()`.

---

## 3. Backend REST API Mapping Catalog (Admin Role)

| Feature Area | HTTP Method | Endpoint Path | Spring Security / PreAuthorize | Request Payload DTO | Response Payload DTO | Status Codes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Pending PGs** | `GET` | `/api/v1/admin/properties/pending` | `@PreAuthorize("hasRole('ADMIN')")` | N/A | `ApiResponse<List<PropertySummaryResponse>>` | `200 OK`, `403 Forbidden` |
| **Verify / Reject PG** | `PATCH` | `/api/v1/admin/properties/{id}/verify` | `@PreAuthorize("hasRole('ADMIN')")` | `VerifyPropertyRequest` (`verified`, `remarks`) | `ApiResponse<PropertyDetailResponse>` | `200 OK`, `400 Bad Request` |
| **Verify / Reject KYC**| `PATCH` | `/api/v1/kyc/{id}/verify` | `@PreAuthorize("hasRole('ADMIN')")` | `KycVerificationRequest` (`status` = `VERIFIED`/`REJECTED`, `rejectionReason`) | `ApiResponse<KycDocumentResponse>` | `200 OK`, `400 Bad Request` |
| **Trigger Monthly Invoices**| `POST` | `/api/v1/invoices/admin/generate-monthly` | `@PreAuthorize("hasRole('ADMIN')")` | Query Param: `billingMonth` (`YYYY-MM-DD`) | `ApiResponse<Map<String, Object>>` (`billingMonth`, `invoicesGenerated`) | `200 OK`, `403 Forbidden` |
| **Get User by ID** | `GET` | `/api/v1/users/{id}` | `@PreAuthorize("hasRole('ADMIN')")` | N/A (Path Variable: `id`) | `ApiResponse<UserResponse>` | `200 OK`, `404 Not Found` |
| **Platform Complaints**| `GET` | `/api/v1/complaints` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | N/A | `ApiResponse<List<ComplaintResponse>>` | `200 OK`, `403 Forbidden` |
| **Property Complaints**| `GET` | `/api/v1/complaints/property/{propertyId}` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | Query Param: `status` | `ApiResponse<List<ComplaintResponse>>` | `200 OK`, `403 Forbidden` |
| **Property Invoices** | `GET` | `/api/v1/invoices/property/{propertyId}` | `@PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")` | N/A | `ApiResponse<List<InvoiceResponse>>` | `200 OK`, `403 Forbidden` |
| **System Health** | `GET` | `/api/v1/health` | Public / Open | N/A | `ApiResponse<HealthResponse>` | `200 OK` |

---

## 4. State Management (BLoC Events & States)

### 4.1 AdminPropertyBloc
- **Events**:
  - `FetchPendingPropertiesRequested()`
  - `VerifyPropertyRequested(int propertyId, bool verified, String? remarks)`
- **States**:
  - `AdminPropertyInitial`
  - `AdminPropertyLoading`
  - `PendingPropertiesLoaded(List<PropertySummaryModel> properties)`
  - `PropertyVerificationSuccess(String message, PropertyDetailModel property)`
  - `AdminPropertyError(String message)`

### 4.2 AdminKycBloc
- **Events**:
  - `FetchPendingKycRequested()`
  - `VerifyKycDocumentRequested(int documentId, String status, String? rejectionReason)`
- **States**:
  - `AdminKycInitial`
  - `AdminKycLoading`
  - `PendingKycLoaded(List<KycDocumentModel> documents)`
  - `KycVerificationSuccess(String message, KycDocumentModel document)`
  - `AdminKycError(String message)`

### 4.3 AdminInvoiceBloc
- **Events**:
  - `TriggerMonthlyInvoicingRequested(DateTime billingMonth)`
- **States**:
  - `AdminInvoiceInitial`
  - `AdminInvoiceGenerating`
  - `MonthlyInvoicingSuccess(DateTime billingMonth, int invoicesGenerated)`
  - `AdminInvoiceError(String message)`

---

## 5. Mobile Navigation & Guard Rules

```dart
// Route Guard Example for Admin Protected Routes
String? adminRouteGuard(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;
  final isAuth = authState is AuthSuccess;
  final role = isAuth ? authState.user.role : null;

  final isAdminPath = state.uri.path.startsWith('/admin');

  if (isAdminPath) {
    if (!isAuth) return '/login?redirect=${state.uri.path}';
    if (role != 'ADMIN') return '/discovery';
  }
  return null;
}
```
