# Adaro App — Implementation Plan
> Screens: Root → Home (Tracker) → History → Settings
> Reference design: adora-tracker.zip (OpenDesign export)

---

## Current State Assessment

- `HomePage` is a placeholder stub (`Center(child: Text('Home'))`)
- Router has `HomeRoute` as a flat top-level route — needs to become a shell route with nested tabs
- No `flutter_map`, `geolocator`, or background location packages present
- BLoC pattern: `@injectable`, freezed sealed unions, event/state split across files, `part of` convention
- Typography uses `fsp()` scaling — all design spec px values should go through this
- `AppColors` is missing: `primaryBg`, `text3/text4`, `borderLight`, and `navBg`
- `AppSpacing` already covers the 4/8/12/16/24px scale and 24px horizontal margin — no additions needed
- No `assets/fonts/` section in pubspec — Inter is referenced but not declared; needs verification or system font fallback note

---

## 1. New Dependencies

Add to `pubspec.yaml` `dependencies`:

| Package | Version | Purpose |
|---|---|---|
| `flutter_map` | `^8.1.1` | OSM tile map for tracker screen |
| `latlong2` | `^0.9.1` | `LatLng` type required by flutter_map |
| `geolocator` | `^13.0.4` | Foreground location stream |
| `background_fetch` | `^1.2.3` | Background location polling (iOS BGAppRefreshTask + Android JobScheduler) |
| `sqflite` | `^2.4.2` | Local SQLite for coordinate history |
| `path_provider` | `^2.1.5` | DB file path resolution |
| `intl` | `^0.20.2` | Date formatting in history screen |

**Notes:**
- `background_fetch` is preferred over `flutter_background_geolocation` (lighter, no commercial license). Pairs with `geolocator` for the actual fix.
- `sqflite` over drift for this use case — coordinate rows are simple, no complex relations, less codegen overhead.
- `latlong2` is a transitive peer of `flutter_map` — pin explicitly to avoid version conflicts.
- Check `permission_handler` already covers `locationAlways` on both platforms — it does as of v12.

**Platform config required (not pubspec):**
- `AndroidManifest.xml`: `ACCESS_BACKGROUND_LOCATION`, `FOREGROUND_SERVICE`, `RECEIVE_BOOT_COMPLETED`
- `Info.plist`: `NSLocationAlwaysAndWhenInUseUsageDescription`, `NSLocationWhenInUseUsageDescription`, `UIBackgroundModes: [fetch, location]`

---

## 2. Color System Updates

**File:** `lib/src/core/components/theme/app_colors.dart`

Colors to add (missing from current file):

| Constant Name | Hex | Design Token |
|---|---|---|
| `primaryBg` | `#E8F5E9` | Primary BG — card tint, badge bg |
| `textTertiary` | `#94A3B8` | Text3 — secondary labels |
| `textQuaternary` | `#CBD5E1` | Text4 — placeholder, disabled |
| `borderLight` | `#F1F5F9` | BorderLight — dividers, subtle separators |
| `navBg` | `#1B3D2F` | Nav pill background |

**Rename note:** `primaryLight` is currently `#E3F2FD` (blue tint — wrong). It should either be deleted or renamed. `primaryBg` (`#E8F5E9`) is the correct green-tinted background. Audit all usages of `primaryLight` before removal.

**No change needed:** `primary`, `primaryDark`, `success`, `warning`, `danger`, `offWhiteBg`, `surfaceWhite`, `textPrimary`, `textSecondary`, `border` — all match the spec exactly.

---

## 3. Directory Structure

New files only (existing files untouched unless noted):

```
lib/src/
├── core/
│   ├── components/
│   │   └── theme/
│   │       └── app_colors.dart          ← MODIFY (add 5 colors)
│   └── data/
│       ├── database/
│       │   ├── app_database.dart         ← SQLite open/init
│       │   └── coordinate_dao.dart       ← CRUD for coordinates table
│       └── models/
│           └── coordinate_record.dart    ← Freezed model (id, lat, lng, timestamp, accuracy)
│
└── features/
    ├── root/
    │   ├── pages/
    │   │   └── root_page.dart            ← AutoTabsScaffold shell
    │   ├── managers/
    │   │   ├── root_cubit.dart           ← @injectable Cubit (tab index, minor UI state)
    │   │   └── root_state.dart           ← Freezed state
    │   └── widgets/
    │       └── c_pill_nav_bar.dart       ← Pill nav, animated tab items
    │
    ├── home/
    │   ├── pages/
    │   │   └── home_page.dart            ← REWRITE (Tracker screen)
    │   ├── managers/
    │   │   ├── tracker_cubit.dart        ← Location stream, tracking toggle
    │   │   └── tracker_state.dart        ← Freezed (position, isTracking, today stats)
    │   └── widgets/
    │       ├── c_live_map.dart           ← flutter_map tile + marker
    │       ├── c_coords_card.dart        ← Coordinate display card (monospace)
    │       ├── c_tracking_toggle.dart    ← BG tracking on/off row
    │       └── c_today_stats_row.dart    ← Distance/points/duration stat chips
    │
    ├── history/
    │   ├── pages/
    │   │   └── history_page.dart         ← Filter tabs + list
    │   ├── managers/
    │   │   ├── history_cubit.dart        ← @injectable, loads from DB
    │   │   └── history_state.dart        ← Freezed (filter, records, loading)
    │   └── widgets/
    │       ├── c_filter_tab_bar.dart     ← Today/Yesterday/This Week/All pill tabs
    │       ├── c_stats_row.dart          ← 3-card stats (points, distance, duration)
    │       └── c_coordinate_list_item.dart ← Single coordinate row
    │
    └── settings/
        ├── pages/
        │   └── settings_page.dart        ← Permission rows + options
        ├── managers/
        │   ├── settings_cubit.dart       ← @injectable, reads/writes SharedPrefs
        │   └── settings_state.dart       ← Freezed (interval, batteryOptimization, etc.)
        └── widgets/
            ├── c_permission_row.dart     ← Permission status + open settings row
            ├── c_interval_selector.dart  ← Segmented control (15s/30s/1m/5m)
            ├── c_settings_toggle_row.dart ← Generic labeled toggle row
            ├── c_battery_warning_box.dart ← Amber warning callout box
            └── c_danger_button.dart      ← "Clear All Data" destructive button
```

---

## 4. Router Changes

**File:** `lib/src/core/config/app_router.dart`

Current flat structure becomes a shell with nested children:

```
AppRouter routes:
  SplashRoute          (initial: true)
  IntroRoute
  WizardRoute
  RootRoute            ← NEW shell route (replaces flat HomeRoute)
    ├── HomeRoute      ← nested child (tab 0, Tracker)
    ├── HistoryRoute   ← nested child (tab 1)
    └── SettingsRoute  ← nested child (tab 2)
```

Key changes:
- `HomeRoute` moves from top-level to a child of `RootRoute`
- `RootPage` carries `@RoutePage()` and wraps `AutoTabsScaffold`
- `RootRoute` uses `AutoRoute(page: RootRoute.page, children: [...])` — no `path` needed for tab children
- After wizard completion, navigate to `RootRoute` (currently navigates to `HomeRoute` — update in `wizard_page.dart` listener)
- Re-run `build_runner` after changes to regenerate `app_router.gr.dart`

---

## 5. Implementation Steps

### Step 1 — Colors + Router + Codegen (Foundation)

> ⚠️ Do this first — everything else depends on generated route classes.

1. Add 5 colors to `app_colors.dart`
2. Create stub `RootPage`, `HistoryPage`, `SettingsPage` (empty `@RoutePage()` widgets)
3. Update `app_router.dart` to nest routes under `RootRoute`
4. Update wizard completion navigation: `HomeRoute()` → `RootRoute()`
5. Run `dart run build_runner build --delete-conflicting-outputs`

---

### Step 2 — Root Shell (`root_page.dart` + `c_pill_nav_bar.dart`)

**Files to create:**
- `lib/src/features/root/pages/root_page.dart`
- `lib/src/features/root/managers/root_cubit.dart`
- `lib/src/features/root/managers/root_state.dart`
- `lib/src/features/root/widgets/c_pill_nav_bar.dart`

**Key classes:**
- `RootPage extends StatelessWidget` — `@RoutePage()`, wraps `AutoTabsScaffold`
- `AutoTabsScaffold(routes: [HomeRoute(), HistoryRoute(), SettingsRoute()], bottomNavigationBuilder: (_, tabsRouter) => CPillNavBar(tabsRouter: tabsRouter))`

**Implementation notes:**
- `extendBody: true` so the floating pill nav overlays content
- Each tab page needs a `SizedBox(height: 80)` spacer at bottom to avoid content hiding behind nav
- `FadeTransition` between tabs
- `RootPage` does not need its own `Scaffold` — `AutoTabsScaffold` provides it

---

### Step 3 — Pill Nav Bar (`c_pill_nav_bar.dart`)

**Design spec:**
- Outer container: `134×52`, centered, `Align(bottomCenter)` + `Padding(bottom: 24)`
- Background: `AppColors.navBg` (`#1B3D2F`), `BorderRadius.circular(26)`
- Active item: white filled circle `38×38`, icon in `AppColors.navBg` (dark green on white)
- Inactive item: icon only, `Colors.white.withOpacity(0.6)`, no label
- Active tab expands to show label — `AnimationController(duration: 200ms)` + `SizeTween`
- 3 tabs: Tracker (`LucideIcons.mapPin`), History (`LucideIcons.list`), Settings (`LucideIcons.settings`)
- Active label: `11px w600 uppercase`
- Total pill width stays fixed at `134` — use `AnimatedContainer` per item

---

### Step 4 — Home / Tracker Screen

**Files to create:**
- `lib/src/features/home/pages/home_page.dart` (rewrite)
- `lib/src/features/home/managers/tracker_cubit.dart`
- `lib/src/features/home/managers/tracker_state.dart`
- `lib/src/features/home/widgets/c_live_map.dart`
- `lib/src/features/home/widgets/c_coords_card.dart`
- `lib/src/features/home/widgets/c_tracking_toggle.dart`
- `lib/src/features/home/widgets/c_today_stats_row.dart`

**Layout:** `Stack([CLiveMap (full bleed), Column(bottom cards)])` — map fills screen, cards float over it.

**Key classes:**
- `TrackerCubit` — `@injectable`, manages `Geolocator.getPositionStream()`, tracking toggle, today's stat aggregates
- `TrackerState` — freezed: `initial`, `active({Position? position, bool isTracking, int todayPoints, double todayDistanceM})`
- `CLiveMap` — `FlutterMap` with `TileLayer` (OSM) + `MarkerLayer` for current position + `MapController` for programmatic camera
- `CCoordsCard` — lat/lng in `21px monospace w600`, accuracy in `textSecondary`
- `CTrackingToggle` — labeled row + `Switch`, dispatches to `TrackerCubit`
- `CTodayStatsRow` — `Row` of 3 `_StatChip` (Points, Distance, Duration)

**Notes:**
- Location stream: `distanceFilter: 10` (metres) to avoid GPS jitter noise in DB
- `MapController` needed for programmatic camera updates when position changes
- Monospace font: use `fontFamily: 'monospace'` (system fallback) since Inter has no mono variant

---

### Step 5 — History Screen

**Files to create:**
- `lib/src/features/history/pages/history_page.dart`
- `lib/src/features/history/managers/history_cubit.dart`
- `lib/src/features/history/managers/history_state.dart`
- `lib/src/features/history/widgets/c_filter_tab_bar.dart`
- `lib/src/features/history/widgets/c_stats_row.dart`
- `lib/src/features/history/widgets/c_coordinate_list_item.dart`

**Key classes:**
- `HistoryCubit` — `@injectable`, loads from `CoordinateDao`, filters records
- `HistoryFilter` — enum: `today`, `yesterday`, `thisWeek`, `all`
- `CFilterTabBar` — horizontal row of 4 pill chips (filled `AppColors.primary` when active)
- `CStatsRow` — 3 white surface cards (Points, Distance, Avg Accuracy)
- `CCoordinateListItem` — monospace coords + `HH:mm:ss` timestamp + accuracy badge

**Notes:**
- Filter tabs are NOT `TabBar` — custom tappable chips
- `ListView.separated` with `Divider(color: AppColors.borderLight)`
- Stats computed in-cubit from filtered list (no extra DB query)
- Cubit re-queries DB on filter change

---

### Step 6 — Settings Screen

**Files to create:**
- `lib/src/features/settings/pages/settings_page.dart`
- `lib/src/features/settings/managers/settings_cubit.dart`
- `lib/src/features/settings/managers/settings_state.dart`
- `lib/src/features/settings/widgets/c_permission_row.dart`
- `lib/src/features/settings/widgets/c_interval_selector.dart`
- `lib/src/features/settings/widgets/c_settings_toggle_row.dart`
- `lib/src/features/settings/widgets/c_battery_warning_box.dart`
- `lib/src/features/settings/widgets/c_danger_button.dart`

**Key classes:**
- `SettingsCubit` — `@injectable`, reads/writes `SharedPreferences`, refreshes permission status on `AppLifecycleState.resumed`
- `TrackingInterval` — enum: `s15`, `s30`, `m1`, `m5` with `label` getter
- `CPermissionRow` — icon + label + `Granted`/`Denied` badge + "Open Settings" button
- `CIntervalSelector` — custom 4-segment `Row` (not Material `SegmentedButton`)
- `CBatteryWarningBox` — amber `#FEF3C7` bg, `LucideIcons.triangleAlert`, body text
- `CDangerButton` — full-width `AppColors.danger` button with confirm `AlertDialog` before delete

**Notes:**
- `CBatteryWarningBox` shows only when `TrackingInterval.s15` is selected
- "Clear All Data" confirm dialog uses standard `AlertDialog`, not `CDangerButton` inside it
- After clear, broadcast via DAO `Stream` or navigate back so `HistoryPage` reloads on next init

---

## 6. Component Inventory

| File | Description |
|---|---|
| `root/widgets/c_pill_nav_bar.dart` | Floating dark-green pill nav with 3 animated tabs; active tab expands to show label |
| `home/widgets/c_live_map.dart` | Full-screen OSM tile map with current position marker |
| `home/widgets/c_coords_card.dart` | White card showing lat/lng in 21px monospace, accuracy subtitle |
| `home/widgets/c_tracking_toggle.dart` | Labeled row toggle for enabling background location tracking |
| `home/widgets/c_today_stats_row.dart` | 3-chip row: today's point count, distance, elapsed duration |
| `history/widgets/c_filter_tab_bar.dart` | Horizontal scrollable pill tabs: Today / Yesterday / This Week / All |
| `history/widgets/c_stats_row.dart` | 3 white surface cards with metric label + value |
| `history/widgets/c_coordinate_list_item.dart` | List row: monospace coords + timestamp + accuracy badge |
| `settings/widgets/c_permission_row.dart` | Icon + permission name + status badge + "Open Settings" action |
| `settings/widgets/c_interval_selector.dart` | Custom 4-segment control for polling interval selection |
| `settings/widgets/c_settings_toggle_row.dart` | Generic labeled Switch row with optional sublabel |
| `settings/widgets/c_battery_warning_box.dart` | Amber callout box warning about battery drain |
| `settings/widgets/c_danger_button.dart` | Full-width red destructive button with confirm-before-action guard |

---

## 7. Data Layer Stubs

### Model — `lib/src/core/data/models/coordinate_record.dart`

```dart
// Freezed model
CoordinateRecord {
  final int? id          // SQLite rowid
  final double latitude
  final double longitude
  final double accuracy  // metres
  final DateTime timestamp
}
// toMap() / fromMap() for sqflite — implement manually (not generated)
```

### Database — `lib/src/core/data/database/app_database.dart`

- `@singleton` injectable, opens `adaro.db` once
- Table: `coordinates (id INTEGER PRIMARY KEY AUTOINCREMENT, latitude REAL, longitude REAL, accuracy REAL, timestamp INTEGER)`
- Timestamp stored as Unix epoch milliseconds
- Index: `CREATE INDEX idx_coordinates_timestamp ON coordinates(timestamp)`

### DAO — `lib/src/core/data/database/coordinate_dao.dart`

- `@injectable`, receives `AppDatabase` via DI
- `insert(CoordinateRecord)`, `queryByDateRange(DateTime from, DateTime to)`, `queryAll()`, `deleteAll()`
- `queryByDateRange` uses `WHERE timestamp >= ? AND timestamp < ?`

### BLoC Stubs

| Cubit | State variants | Injectable |
|---|---|---|
| `RootCubit` | `initial` (or omit entirely) | `@injectable` |
| `TrackerCubit` | `initial`, `active` | `@injectable` |
| `HistoryCubit` | `initial`, `loading`, `active` | `@injectable` |
| `SettingsCubit` | `initial`, `active` | `@injectable` |

---

## Key Risks & Cross-Cutting Notes

1. **⚠️ Router migration first**: Wizard completion currently navigates to `HomeRoute()`. Update to `RootRoute()` before running codegen or you'll get a runtime navigation crash.

2. **Codegen required**: After adding `RootRoute`, `HistoryRoute`, `SettingsRoute` — must run `dart run build_runner build --delete-conflicting-outputs`. Compilation will break until this is done.

3. **Inter font**: `app_typography.dart` references `fontFamily: 'Inter'` but no font assets are declared in `pubspec.yaml`. Either add font assets or remove the override and rely on system fonts. Resolve before building new screens.

4. **`extendBody` + bottom padding**: With `extendBody: true` on `AutoTabsScaffold`, content renders behind the pill nav. Every tab page needs a `SizedBox(height: 80)` spacer or equivalent at the bottom of its scroll view. Establish as a documented convention.

5. **Background location on iOS**: `background_fetch` / iOS 13+ throttles background tasks to ~15min regardless of configured interval. Mention this limitation in `CBatteryWarningBox` text.
