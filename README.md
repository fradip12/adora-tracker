# Adora — GPS Tracker

A Flutter app for continuous GPS location tracking with background and terminated-state support, session history, and per-device tracking controls.

---

## Features

### Onboarding

Guided first-launch flow that walks the user through granting the required permissions before reaching the main app.

- Animated splash screen
- Introduction slides
- Step-by-step permission wizard (location, notification, battery optimisation)

https://github.com/user-attachments/assets/1205a777-d98b-4b1f-aaf4-24abf5fd640e



---

### Live Tracking (Home)

Real-time GPS tracking with a live map view and coordinate readout.

- Start / stop tracking with a single tap
- Live map that follows the current position and draws the track polyline
- Coordinate card showing latitude, longitude, and GPS accuracy
- Tracking status chip (active / idle)
- Persistent foreground notification showing current coordinates and tracking mode while a session is running

> https://github.com/user-attachments/assets/ce3c7f93-9a34-4f3a-96e4-4e0337f0fb3c

---

### Background Tracking

Tracking continues when the app is moved to the background (home button / app switcher).

- Foreground service keeps recording coordinates while the app is not visible
- Notification persists so the user can see live coordinates without opening the app
- Configurable in Settings → **Background Tracking**

>https://github.com/user-attachments/assets/25497002-43a5-4170-a90d-2cfdf4359c51


---

### Terminated-State Tracking

Tracking survives a full app close (swiped away from the task switcher or killed by the OS).

- Foreground service is preserved across app death
- On next launch the session is automatically detected and the tracking state is fully restored
- Configurable in Settings → **Continues After Close**

> https://github.com/user-attachments/assets/f7f4ea69-df48-413c-a681-07264088bbff


---

### Session History

Browse all past and current tracking sessions with filterable date ranges.

- Filter by **Today**, **Yesterday**, **This Week**, or **All**
- Stats card summarising total sessions and coordinate count for the selected range
- Accuracy badge per coordinate entry (high / medium / low)
- Tap a session to open the detail view

---

### Session Detail

Full coordinate log for a single session.

- Scrollable list of every recorded point with timestamp and accuracy
- Duration and start time displayed in the header

---

### Settings

#### Tracking

| Setting | Description | Default |
|---|---|---|
| Tracking Interval | How often a coordinate is recorded — 10 s, 30 s, 1 min | 30 s |
| Background Tracking | Keep recording when the app is in the background | On |
| Continues After Close | Restore the session when the app is reopened after being killed | Off |
| Persistent Notification | Show live coordinates in the notification while tracking | On |


#### Permissions

Live status of Location, Notification, and Battery Optimisation permissions with one-tap shortcuts to the system settings page.

#### Language

Switch the app language. Supported locales: English, Japanese.

> https://github.com/user-attachments/assets/85294a24-e96c-4aa7-b8e1-5d9bf615f7a3

---

## Tech Stack

| Layer | Library |
|---|---|
| State management | `flutter_bloc` + `freezed` |
| Navigation | `auto_route` |
| Database | `drift` (SQLite) |
| Foreground service | `flutter_foreground_task` |
| Maps | `flutter_map` |
| Location | `geolocator` |
| Dependency injection | `get_it` + `injectable` |
| i18n | `slang` |
| Preferences | `shared_preferences` |

---

## Getting Started

This project uses [FVM](https://fvm.app/) to pin Flutter `3.38.3`.

```bash
# Full setup (clean + pub get + i18n + code generation)
make initialize

# Run
make run

# Re-generate i18n only
make slang

# Re-generate freezed / injectable / auto_route
make generate
```

> Never edit `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, or `app_di.config.dart` — they are fully generated.
