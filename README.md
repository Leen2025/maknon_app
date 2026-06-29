# مَكنون (Maknoon)


<img width="1381" height="1139" alt="dc8508b5-feef-4eb9-841b-2a9fd2ca1492" src="https://github.com/user-attachments/assets/3750e46f-632b-484a-9883-790a7d4cd96b" />
















<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-29 at 18 09 35" src="https://github.com/user-attachments/assets/a90e5edf-7601-47c5-99dc-b2f2032cb8e7" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-29 at 18 09 23" src="https://github.com/user-attachments/assets/35e62a7f-196b-4906-a4c2-e4d44d98a895" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-29 at 18 09 57" src="https://github.com/user-attachments/assets/adc643b7-b996-4ccf-8fc2-bf4f7849f544" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-29 at 18 03 38" src="https://github.com/user-attachments/assets/2f6eb8d8-77cc-4c96-883d-fe325cb0ecbf" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-23 at 20 18 18" src="https://github.com/user-attachments/assets/66649d23-9cc3-4a80-acd8-d66fc753f487" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-29 at 18 08 47" src="https://github.com/user-attachments/assets/51c0f119-2885-47e8-8ac7-c9e32cf52df5" />


A Flutter app for storing and managing receipts, warranties, return/exchange deadlines, and subscription renewals — with local reminders before anything expires.

**Local-first** — all data lives on the device in Hive. No login, no cloud, fully offline.

---

## Architecture

Clean Architecture with feature-based folders. Each feature has three layers:

```
features/<feature>/
  data/           # Hive models, datasources, repository implementations
  domain/         # Pure entities, repository contracts, use cases
  presentation/   # Cubits, pages, feature-specific widgets
```

State management uses **Cubit** (from `flutter_bloc`). Routing uses **GoRouter** with a `StatefulShellRoute` for the bottom nav. Dependency injection uses **get_it** — wired manually in `lib/core/di/injector.dart`.

---

## Project structure

```
lib/
├── core/
│   ├── constants/         # colors, spacing, strings, hive box names
│   ├── di/                # service locator (injector.dart)
│   ├── errors/            # Failure classes
│   ├── router/            # AppRoutes + AppRouter
│   ├── services/          # NotificationService, ImageStorageService
│   ├── theme/             # AppTheme
│   ├── utils/             # date utils, currency formatter, picker helpers
│   └── widgets/           # AppScaffold, DeadlineCard, CountdownBadge, etc.
│
├── features/
│   ├── home/              # Dashboard
│   ├── receipts/          # Receipts feature (data/domain/presentation)
│   ├── warranties/        # Warranties feature
│   ├── subscriptions/     # Subscriptions feature
│   └── reminders/         # Reminders aggregate + scheduling use cases
│
├── app.dart
└── main.dart
```

---

## Setting up

### 1. Generate the platform folders

This package ships with `lib/`, `pubspec.yaml`, and permission snippets — but **not** the `android/`, `ios/`, `web/` folders, since those should match your local Flutter SDK version. Generate them with:

```bash
cd maknoon
flutter create . --org com.maknoon --project-name maknoon
flutter pub get
```

### 2. Add platform permissions

**Android** — open `android/app/src/main/AndroidManifest.xml` and merge the contents of `android/PERMISSIONS_SNIPPET.xml` into it (the snippet shows exactly where each block goes).

**iOS** — open `ios/Runner/Info.plist` and add the keys from `ios/PERMISSIONS_SNIPPET.plist`.

### 3. Set Android `minSdkVersion`

In `android/app/build.gradle`, make sure:

```gradle
minSdkVersion 21
```

`flutter_local_notifications` requires at least 21.

### 4. Run

```bash
flutter run
```

---

## Packages used

| Package | Purpose |
|---|---|
| `flutter_bloc` + `equatable` | State management (Cubits) |
| `go_router` | Declarative routing with bottom-nav shell |
| `get_it` | Dependency injection |
| `hive` + `hive_flutter` | Local key-value DB for receipts/warranties/subscriptions |
| `path_provider` | App documents directory for stored images |
| `flutter_local_notifications` + `timezone` | Reminders before deadlines |
| `image_picker` | Camera + gallery access for receipt/warranty photos |
| `intl` | Arabic date and number formatting |
| `uuid` | Stable IDs for entities |

---

## How reminders work

When a receipt/warranty/subscription is saved, the relevant `ScheduleReminders…` use case is called. It:

1. Cancels any previously scheduled notifications for that entity ID.
2. Schedules new notifications via `NotificationService.schedule(...)`.

Reminder windows:

- **Receipts** — 3 days before & day-of for both return and exchange deadlines.
- **Warranties** — 30 days, 7 days, and day-of before expiry.
- **Subscriptions** — 3 days and day-of before renewal.

Notification IDs are stable hashes of `(entityId, tag)` so re-scheduling cleanly replaces old reminders.

---

## Optional: custom Arabic font

The theme references `IBMPlexSansArabic`. To use it:

1. Download the family from [Google Fonts → IBM Plex Sans Arabic](https://fonts.google.com/specimen/IBM+Plex+Sans+Arabic).
2. Drop the `.ttf` files into `assets/fonts/`.
3. Add this block to `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: IBMPlexSansArabic
      fonts:
        - asset: assets/fonts/IBMPlexSansArabic-Regular.ttf
        - asset: assets/fonts/IBMPlexSansArabic-Medium.ttf
          weight: 500
        - asset: assets/fonts/IBMPlexSansArabic-SemiBold.ttf
          weight: 600
```

If you skip this, the app will fall back to the system Arabic font — still looks fine.

---

## What's next

Logical extensions that aren't in this v1:

- Search & filtering on receipts/warranties.
- Categories or tags on receipts (groceries, electronics, etc.).
- CSV export of all data.
- Encrypted Hive boxes (a passphrase to unlock the app).
- Optional cloud backup (Firebase or Supabase) — keeping the same domain layer means you only swap the repository implementation.
