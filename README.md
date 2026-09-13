# Campus_Connect — Institute Mobile Platform

Campus_Connect is an enterprise-grade mobile academic management and student engagement application built for educational institutions. It unifies institutional notices, attendance monitoring, academic schedules, club event discovery, and student gamification into a single, high-performance platform.

## Key Modules by Role

### Student
* **Live Dashboard:** Time-sensitive greetings, dynamic stat counters, streak counter, and notification alerts.
* **Attendance Board:** Subject-wise breakdown, aggregate percentage metrics, low-attendance alerts (< 75%), and attendance recovery calculators.
* **Gamification & Rewards:** Consecutive daily attendance streaks (with automated weekend bridging), level progression, and milestone badge achievements.
* **Academic Hub:** Daily timetable viewer, examination roster with countdown timers, faculty directory, and academic calendar.
* **Campus Events:** Discovery feed with category filters (Technical, Cultural, Sports, Literary) and direct browser-based registration links.
* **Notices & Realtime Inbox:** High-priority pinned announcements and instant notifications triggered via PostgreSQL Realtime.

### Club Admin
* **Club Management Console:** Restricted management interface scoped strictly to the administrator's assigned club.
* **Event Operations:** Full lifecycle management (draft, publish, venue update, time modification, cancellation).
* **Multi-Tenant Isolation:** Protected by PostgreSQL Row Level Security (RLS). A Club Admin cannot view unauthorized management panels or modify events belonging to other clubs.

### Institute Admin
* **Executive Portal:** Centralized management console for institutional content.
* **Notices Broadcaster:** Publish, edit, and categorize official institute circulars with high-priority push flags.
* **Faculty Directory Manager:** Full CRUD interface for maintaining campus academic faculty and office locations.
* **Lead Appointments:** Atomic role-promotion engine to assign or revoke Club Admin status for student accounts.

## Technology Stack
* **Frontend:** Flutter (Dart 3, Material 3, RepaintBoundary-isolated animations).
* **State Management:** Riverpod 2.0 (Decoupled, observable state layer).
* **Routing:** GoRouter 14 (Role-guarded navigation trees with redirect protection).
* **Backend:** Supabase (PostgreSQL 15, Auth with PKCE, Realtime Publications, and Row Level Security).
* **Local Cache:** Zero-dependency in-memory TTL cache to minimize network data consumption.

## Setup & Local Installation

### Prerequisites
* Flutter SDK >= 3.3.0
* Android SDK (API 34)
* Physical Android device (Developer options and USB debugging enabled)
* Supabase project instance

### Environment Variables
Configure your Supabase URL and public anonymous key in `lib/core/config/supabase_config.dart` or pass them as compile-time defines:

```bash
flutter run \
  --dart-define=SUPABASE_URL=[https://your-project.supabase.co](https://your-project.supabase.co) \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
