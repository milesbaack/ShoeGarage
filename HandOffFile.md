## 1. Architecture & Dependency Overview

* **Core Objective**: Develop an iOS app to automatically track shoe mileage by passively syncing Apple Health workouts and allowing users to assign mileage via interactive push notifications.
* **Key Assumptions**: The user is targeting iOS 16+ (using modern Swift concurrency and HealthKit APIs). CloudKit quota limits are sufficient for user data and shoe image syncing without requiring a dedicated backend.
* **State & Data Migrations**: Initial setup requires scaffolding a Drift (SQLite) database with `Shoes` and `Activities` tables, alongside a `UserDefaults` App Group suite for the native Swift notification bridge. A migration path from zero state to populated state via an initial 30-day HealthKit sync is required.
* **Critical Bottlenecks & Risks**: Apple App Store Review (requires explicit `NSHealthShareUsageDescription` justification and safe background execution limits). Background execution reliability (relying on `HKObserverQuery` and `UserDefaults` instead of waking the Flutter engine). Overlapping workout deduplication logic.

## 2. Sprint Roadmap Table

| ID | Item | Estimated Complexity | Dependencies | Status |
| --- | --- | --- | --- | --- |
| `[EPIC-01]` | Foundation & Native Architecture | - | None | Complete |
| `[EPIC-02]` | UI Structure & State Management | - | `[EPIC-01]` | Complete |
| `[FEAT-01]` | Background HealthKit Observer Pipeline | - | `[EPIC-01]` | Complete |
| `[FEAT-02]` | Local Persistence & Cloud Backup | - | `[EPIC-01]` | Complete |
| `[ENABLER-01]` | Scaffold Drift Schema & App Group Setup | S (2 pts) | None | Complete |
| `[ENABLER-02]` | Implement Native Swift HKObserverQuery | M (5 pts) | `[ENABLER-01]` | Complete |
| `[STORY-01]` | Background Workout Notification & Queueing | M (5 pts) | `[ENABLER-02]` | Complete |
| `[STORY-02]` | Initial 30-Day HealthKit Sync & Deduplication | L (8 pts) | `[ENABLER-01]` | Complete |
| `[STORY-03]` | Garage Tab: Shoe Roster & Battery Life UI | M (3 pts) | `[ENABLER-01]` | Complete |
| `[STORY-04]` | Activity Tab: Unassigned Run Carousel | M (5 pts) | `[STORY-01]`, `[STORY-02]` | Complete |
| `[STORY-05]` | Shoe Lifecycle Edge Cases & Navigation Reorganization | M (5 pts) | `[STORY-03]`, `[STORY-04]` | Complete |
| `[STORY-06]` | Shoe Detail Screen & Cost-per-Mile Tracker | M (5 pts) | `[STORY-05]` | Complete |
| `[STORY-07]` | Assigned Workout History & Reassign Option | M (5 pts) | `[STORY-04]` | Complete |
| `[STORY-08]` | Real Shoe Photos (Camera & Photo Library) | M (5 pts) | `[STORY-06]` | Complete |
| `[STORY-09]` | Default Shoe for Workout Types | M (5 pts) | `[STORY-03]`, `[STORY-04]` | Complete |
| `[STORY-10]` | Unit Toggle (Miles vs. Kilometers) | M (5 pts) | `[STORY-05]`, `[STORY-06]` | Complete |
| `[STORY-11]` | Rotation Analytics & Retirement Projections | M (5 pts) | `[STORY-06]`, `[STORY-10]` | Complete |
| `[UI-01]` | Performance Studio UI & Tactile Psychology Overhaul | M (5 pts) | `[STORY-11]` | Complete |
| `[RELEASE-01]` | App Store Production Assets, Website & Bundle ID | M (5 pts) | `[UI-01]` | Complete |

### `[ENABLER-01]` Scaffold Drift Schema & App Group Setup

* **Parent**: `[FEAT-02]`
* **Complexity**: S (2 pts)
* **Dependencies**: None

**User Story**:

* **As a** system architect,
* **I want** to initialize the Drift SQLite tables and the shared iOS `UserDefaults` suite,
* **So that** both Flutter and native Swift have a secure, structured place to read/write shoe metadata and assignment queues.

**Acceptance Criteria**:

* **Scenario 1: Schema Initialization**
* **Given** a fresh app install
* **When** the database initializes
* **Then** the `Shoes` and `Activities` tables are created with the exact properties defined in the handoff document.


* **Scenario 2: Shared UserDefaults Communication**
* **Given** the Flutter app updates active shoe data
* **When** it writes to `UserDefaults`
* **Then** the native Swift code can successfully read the updated shoe names and IDs.



**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Create `database.dart` defining `Shoes` and `Activities` classes.
* [x] `[TASK-02]` Generate Drift schema files.
* [x] `[TASK-03]` Configure iOS App Group in Xcode to allow shared `UserDefaults` access.
* [x] `[TEST-01]` Unit Test: Verify Drift database table creation and basic CRUD operations.

### `[ENABLER-02]` Implement Native Swift HKObserverQuery

* **Parent**: `[FEAT-01]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[ENABLER-01]`

**User Story**:

* **As a** runner tracking my miles,
* **I want** the app to passively detect when I finish a workout without draining my battery,
* **So that** I don't have to keep the app open while I run.

**Acceptance Criteria**:

* **Scenario 1: Workout Completion Detection**
* **Given** the user has granted Apple Health permissions
* **When** a new `HKWorkout` (running/walking) is saved by the Apple Watch
* **Then** the Swift `HKObserverQuery` in `AppDelegate` is woken in the background within a reasonable time window.


* **Scenario 2: Permission Handling**
* **Given** the user denies HealthKit access
* **When** the observer attempts to run
* **Then** the error is handled gracefully and no notification is triggered.



**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Request HealthKit permissions in Flutter and handle OS-level authorization.
* [x] `[TASK-02]` Write `HKObserverQuery` setup inside `AppDelegate.swift` with `.immediate` background delivery frequency.
* [x] `[TEST-01]` Integration Test: Mock a completed HealthKit workout and verify the background observer fires.

### `[STORY-01]` Background Workout Notification & Queueing

* **Parent**: `[FEAT-01]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[ENABLER-02]`

**User Story**:

* **As a** runner,
* **I want** to receive a notification immediately after a run asking which shoes I wore,
* **So that** I can log my mileage with a single tap.

**Acceptance Criteria**:

* **Scenario 1: Standard Assignment**
* **Given** a background workout is detected
* **When** the native Swift code executes
* **Then** a local push notification fires with contextual action buttons for the user's active shoes.


* **Scenario 2: Queueing the Tap**
* **Given** the notification is displayed
* **When** the user taps "Hoka - Race Day"
* **Then** Swift appends the `[WorkoutID, ShoeID]` pair to the `UserDefaults` Pending Assignments queue.



**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Configure `UNUserNotificationCenter` categories and actions dynamically based on `UserDefaults` shoe data.
* [x] `[TASK-02]` Handle notification action responses in Swift to push data to the queue.
* [x] `[TASK-03]` Implement Riverpod listener on app foreground to read, execute, and clear the `UserDefaults` queue into Drift.
* [x] `[TEST-01]` Integration Test: Verify tapping a notification action successfully updates the Drift database upon next app launch.

### `[STORY-02]` Initial 30-Day HealthKit Sync & Deduplication

* **Parent**: `[FEAT-01]`
* **Complexity**: L (8 pts)
* **Dependencies**: `[ENABLER-01]`

**User Story**:

* **As a** new user,
* **I want** the app to import my last 30 days of runs upon install without spamming me with notifications,
* **So that** my inbox is populated with recent history immediately.

**Acceptance Criteria**:

* **Scenario 1: Stale Workout Suppression**
* **Given** an initial sync fetching 20 historical runs
* **When** the sync completes
* **Then** they are added to the Drift DB with a `null` shoe ID (routing to the Inbox), and *no* push notifications are fired.


* **Scenario 2: Overlapping Duplicates**
* **Given** a new workout sync occurs
* **When** the new workout overlaps by >80% with an existing Drift entry
* **Then** the new workout is discarded, prioritizing native Apple bundles.



**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Implement `HKAnchoredObjectQuery` in Swift/Flutter to fetch historical data.
* [x] `[TASK-02]` Implement the 2-hour stale check to suppress notifications during bulk syncs.
* [x] `[TASK-03]` Write the 80% overlap deduplication logic before inserting into Drift.
* [x] `[TEST-01]` Unit Test: Feed two overlapping workout objects into the deduplication function and ensure only one is preserved.

### `[STORY-03]` Garage Tab: Shoe Roster & Battery Life UI

* **Parent**: `[FEAT-02]`
* **Complexity**: M (3 pts)
* **Dependencies**: `[ENABLER-01]`

**User Story**:

* **As a** runner,
* **I want** to see a dashboard of all my active shoes with a visual battery indicator,
* **So that** I know exactly when it's time to replace a pair.

**Acceptance Criteria**:

* **Scenario 1: Visual Calculation**
* **Given** a shoe has 200 miles and a 400-mile target
* **When** rendered in the Garage tab
* **Then** the linear progress bar shows exactly 50% completion.


* **Scenario 2: Retirement**
* **Given** the user selects "Retire Shoe"
* **When** the action is confirmed
* **Then** `isRetired` is set to true, the shoe moves out of the active roster, and the target lifespan snaps to the current distance.



**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Build the Riverpod provider to stream `isRetired == false` shoes from Drift.
* [x] `[TASK-02]` Create the `ShoeCardWidget` featuring custom layout, photo support, and the linear progress bar.
* [x] `[TASK-03]` Implement the "Retire" logic ensuring the target distance snap behavior.
* [x] `[TEST-01]` UI Test: Verify the progress bar color changes to a warning state when >90% complete.

### `[STORY-04]` Activity Tab: Unassigned Run Carousel

* **Parent**: `[EPIC-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-01]`, `[STORY-02]`

**User Story**:

* **As a** runner with imported or unassigned workouts in my inbox,
* **I want** to review unassigned runs in a carousel deck and assign each run to a shoe in my active rotation with a single tap,
* **So that** my shoe mileage stays accurate even if I missed a lock-screen notification or did a bulk import.

**Acceptance Criteria**:

* **Scenario 1: Presentation**
* **Given** unassigned workouts exist in Drift (`shoeId == null`)
* **When** viewing the Activities tab
* **Then** they are displayed in a clean card carousel showing date, workout type, distance, duration, and source.

* **Scenario 2: Inline Shoe Assignment**
* **Given** an unassigned run card
* **When** the user taps an active shoe chip
* **Then** `db.assignActivityToShoe(activityId: activity.id, shoeId: shoe.id)` executes, the shoe's `currentDistance` increments by the run's mileage, and the activity leaves the unassigned inbox.

* **Scenario 3: Empty State**
* **Given** all runs are assigned (`unassigned.isEmpty`)
* **When** viewing the Activities tab
* **Then** a congratulatory empty state is shown ("All Caught Up! 🎉").

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Create `UnassignedRunCarousel` and `ActivityCardWidget` displaying metrics (date, distance, duration, pace, source).
* [x] `[TASK-02]` Implement quick-assign shoe chips allowing one-tap assignment to active shoes.
* [x] `[TASK-03]` Connect to Riverpod `unassignedActivitiesProvider` and `activeShoesProvider`.
* [x] `[TEST-01]` UI & Integration Test: Verify assigning a run from the carousel updates shoe mileage and removes it from the inbox.

### `[STORY-05]` Shoe Lifecycle Edge Cases & Navigation Reorganization

* **Parent**: `[EPIC-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-03]`, `[STORY-04]`
* **Status**: Complete

**User Story**:

* **As a** runner managing my shoe collection,
* **I want** to edit shoe details, manually add miles, delete shoes, and un-retire shoes back into active rotation,
* **And** access the Nursing Home directly from the Garage while having a dedicated Settings tab on the bottom navigation bar,
* **So that** my shoe lifespans are fully editable, edge cases are covered, and app configuration is easy to manage.

**Acceptance Criteria**:

* **Scenario 1: Un-retire Shoes**
* **Given** a shoe in the Nursing Home
* **When** the user taps 'Un-retire Shoe'
* **Then** a dialog prompts for a new target lifespan (greater than current distance), restores `isRetired = false`, clears `retiredAt`, and moves the shoe back into the Garage active rotation.

* **Scenario 2: Manually Add Miles**
* **Given** an active shoe in the Garage
* **When** the user taps 'Add Miles'
* **Then** a dialog allows entering additional mileage with quick addition chips (+1, +3.1, +5, +10 mi), updating the shoe's total distance in SQLite.

* **Scenario 3: Edit and Delete Shoes**
* **Given** any shoe in the Garage or Nursing Home
* **When** editing or deleting
* **Then** 'Edit Shoe' allows modifying nickname, brand, model, category, target lifespan, and current miles. 'Delete Shoe' shows a destructive confirmation dialog and safely unassigns any linked workouts.

* **Scenario 4: Navigation Reorganization**
* **Given** the bottom navigation bar
* **When** viewing the app
* **Then** destinations are `[Garage, Activities, Settings]`. The Nursing Home is accessible from the Garage screen via the AppBar action button (with retired count badge) and a footer card in the shoe list.

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Add `unretireShoe`, `addMilesToShoe`, `updateShoeDetails`, and `deleteShoe` methods to `AppDatabase` in `database.dart`.
* [x] `[TASK-02]` Create `EditShoeSheet` and dialogs (`AddMilesDialog`, `UnretireDialog`, `DeleteDialog`) in `ShoeCardWidget`.
* [x] `[TASK-03]` Create `NursingHomeScreen` accessible from Garage via AppBar action and list card.
* [x] `[TASK-04]` Create `SettingsScreen` with HealthKit sync, notification permission checks, and garage statistics.
* [x] `[TASK-05]` Reorganize bottom navigation bar to `[Garage, Activities, Settings]`.
* [x] `[TEST-01]` Database Unit Tests: Verify unretire, add miles, update details, and delete shoe with activity nullification.
* [x] `[TEST-02]` UI Tests: Verify Add Miles dialog, Un-retire dialog, and Delete Shoe confirmation in `shoe_card_widget_test.dart`.
* [x] `[TEST-03]` Navigation & Widget Test: Verify 3 tabs (`Garage`, `Activities`, `Settings`) and Nursing Home navigation.

### `[STORY-06]` Shoe Detail Screen & Cost-per-Mile Tracker

* **Parent**: `[EPIC-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-05]`
* **Status**: Complete

**User Story**:

* **As a** runner tracking my gear,
* **I want** to tap any shoe to view its detailed career page, including a real-time cost-per-mile calculation and workout history,
* **So that** I know exactly how much value I am getting out of my investment and can review every run logged in that pair.

**Acceptance Criteria**:

* **Scenario 1: Shoe Detail Page Navigation**
* **Given** an active or retired shoe card in the Garage or Nursing Home
* **When** the user taps the card
* **Then** the app navigates to `ShoeDetailScreen`, displaying hero shoe metadata, status, lifespan gauge, cost-per-mile card, career stats, and workout history.

* **Scenario 2: Real-Time Cost-per-Mile Calculation**
* **Given** a shoe with purchase price $160 and 320 miles logged
* **When** viewing the Cost-per-Mile card
* **Then** the app displays `$0.50 / mi` ($160 / 320). If unpriced, it displays an inviting prompt to set the purchase price.

* **Scenario 3: Inline Price Editing**
* **Given** a shoe in `ShoeDetailScreen`
* **When** tapping "Set Price" or "Edit Price"
* **Then** an interactive dialog updates the shoe's price in SQLite, immediately refreshing the cost-per-mile rate.

* **Scenario 4: Shoe-Specific Workout History**
* **Given** a shoe with assigned workouts
* **When** viewing `ShoeDetailScreen`
* **Then** all workouts assigned to this shoe are rendered chronologically with distance, duration, pace, and device source.

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Add `price` column to `Shoes` table with Drift schema version 2 migration and `updateShoePrice` method.
* [x] `[TASK-02]` Add purchase price input to `AddShoeSheet` and `EditShoeSheet`.
* [x] `[TASK-03]` Build `ShoeDetailScreen` with responsive layout for battery progress, cost-per-mile, stats, and workouts.
* [x] `[TASK-04]` Wire card tap in `ShoeCardWidget` to push `ShoeDetailScreen`.
* [x] `[TEST-01]` Database Unit Tests: Verify price persistence and updates in `test/database_test.dart`.
* [x] `[TEST-02]` UI & Integration Tests: Verify `ShoeDetailScreen` rendering, cost-per-mile calculation, and price editing in `test/shoe_detail_screen_test.dart`.

### `[STORY-07]` Assigned Workout History & Reassign Option

* **Parent**: `[FEAT-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-04]`

**User Story**:

* **As a** runner,
* **I want** to browse my assigned workout history and reassign runs or move them back to my Inbox,
* **So that** accidental assignments can be effortlessly corrected and shoe mileages stay 100% accurate.

**Acceptance Criteria**:

* **Scenario 1: Unified Activities Screen with Segmented Toggle**
* **Given** the user navigates to the Activities tab
* **When** viewing the screen
* **Then** a segmented button offers "Inbox (count)" and "History (count)" views.

* **Scenario 2: Assigned Workout History Card**
* **Given** workouts assigned to shoes in the garage
* **When** viewing the "History" tab
* **Then** each workout card displays distance, duration, pace, workout date, device source, and the assigned shoe's name with an active "Reassign" button.

* **Scenario 3: Reassign to Another Shoe**
* **Given** an assigned workout
* **When** tapping "Reassign" and selecting a different active shoe from the garage
* **Then** the previous shoe's mileage is decremented by the workout distance, the new shoe's mileage is incremented by the workout distance, and the activity's `shoeId` updates in an atomic SQLite transaction.

* **Scenario 4: Move to Inbox (Unassign)**
* **Given** an assigned workout
* **When** tapping "Reassign" and selecting "Move to Inbox (Unassign)"
* **Then** the shoe's mileage is decremented, the activity's `shoeId` is set to `null`, and the workout immediately appears in the "Inbox" carousel.

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Add `watchAssignedActivities()`, `getAssignedActivities()`, `reassignActivityShoe()`, and `unassignActivity()` to `database.dart` with atomic SQLite transaction rollback safety.
* [x] `[TASK-02]` Create `assignedActivitiesProvider` in `providers.dart`.
* [x] `[TASK-03]` Build `ReassignShoeSheet` bottom sheet widget with active shoe rotation selection and "Move to Inbox (Unassign)" action.
* [x] `[TASK-04]` Build `AssignedActivityCard` with metrics, assigned shoe badge, and reassign trigger.
* [x] `[TASK-05]` Build `ActivitiesScreen` with SegmentedButton switching between Inbox and History.
* [x] `[TASK-06]` Wire `ActivitiesScreen` into `lib/main.dart`.
* [x] `[TEST-01]` Unit Tests: Verify mileage adjustments during reassign and unassign in `test/database_test.dart`.
* [x] `[TEST-02]` Widget Tests: Verify SegmentedButton switching, card rendering, and interactive reassign/unassign flows in `test/activities_screen_test.dart`.

### `[STORY-08]` Real Shoe Photos (Camera & Photo Library)

* **Parent**: `[FEAT-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-06]`

**User Story**:

* **As a** runner,
* **I want** to attach real photos of my running shoes using the camera or my photo library,
* **So that** my shoe collection looks personal, recognizable at a glance, and visually stunning.

**Acceptance Criteria**:

* **Scenario 1: Adding a Shoe Photo on Creation**
* **Given** the user is adding a new shoe in `AddShoeSheet`
* **When** tapping "Add Photo"
* **Then** an action sheet prompts "Take Photo" or "Choose from Library", showing a live thumbnail with a delete badge. Upon saving, the photo is permanently persisted to `<appDocDir>/shoe_photos/`.

* **Scenario 2: Card & Detail Screen Photo Display**
* **Given** a shoe with an attached photo
* **When** viewing the Garage roster card or `ShoeDetailScreen`
* **Then** the high-resolution image is rendered with smooth rounded corners in place of generic icons.

* **Scenario 3: Interactive Detail Screen Photo Actions**
* **Given** `ShoeDetailScreen`
* **When** tapping the shoe photo thumbnail
* **Then** the user can choose "View Full Screen" (pinch-and-zoom modal), "Take New Photo", "Choose from Library", or "Remove Photo".

* **Scenario 4: Editing & Removing Photos**
* **Given** `EditShoeSheet`
* **When** removing or replacing a photo
* **Then** the old file is safely deleted from storage and the new path (or null) is updated in Drift SQLite.

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Configure `image_picker` dependency and add `NSPhotoLibraryUsageDescription` & `NSCameraUsageDescription` to `Info.plist`.
* [x] `[TASK-02]` Build `ShoePhotoService` for picking, copying into permanent app documents storage, and deleting orphan photos.
* [x] `[TASK-03]` Build reusable `showPhotoActionSheet` modal.
* [x] `[TASK-04]` Integrate photo picker & preview into `AddShoeSheet` and `EditShoeSheet`.
* [x] `[TASK-05]` Enhance `ShoeDetailScreen` with interactive photo thumbnail and full-screen viewer.
* [x] `[TASK-06]` Add `updateShoePhoto` method to Drift SQLite database.
* [x] `[TEST-01]` Unit Tests: Test `updateShoePhoto` in `test/database_test.dart` and `ShoePhotoService` filesystem operations in `test/shoe_photo_service_test.dart`.
* [x] `[TEST-02]` Widget Tests: Test photo rendering and interaction in `test/shoe_photo_widget_test.dart`.

### `[STORY-09]` Default Shoe for Workout Types

* **Parent**: `[EPIC-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-03]`, `[STORY-04]`

**User Story**:

* **As a** multi-sport runner or walker,
* **I want** to specify a default shoe for specific workout types (Running, Walking, Hiking, Other),
* **So that** new workouts imported into my Inbox can be assigned with a single tap without manual shoe hunting.

**Acceptance Criteria**:

* **Scenario 1: Default Workout Shoes Configuration in Settings**
* **Given** the Settings screen
* **When** viewing the "DEFAULT WORKOUT SHOES" section
* **Then** tiles for Running, Walking, Hiking, and Other display the currently assigned default shoe (or "None (manual selection)"). Tapping a tile opens a picker allowing the user to select any active shoe or clear the default.

* **Scenario 2: 1-Tap Fast Assignment in Inbox Carousel**
* **Given** an unassigned workout in the Inbox whose `workoutType` matches a default shoe
* **When** viewing the workout card
* **Then** a prominent primary button "Assign to Default ([Shoe Name])" with a star icon is rendered at the top, enabling instant 1-tap logging. The default shoe is also placed first in the quick-selection chips.

* **Scenario 3: Roster and Detail Screen Default Badges**
* **Given** a shoe that is assigned as default for one or more workout types
* **When** viewing its card in the Garage roster or its `ShoeDetailScreen`
* **Then** amber `DEFAULT ([TYPE])` badges with star icons are displayed. In `ShoeDetailScreen`, the overflow menu includes a "Workout Defaults" toggle sheet.

* **Scenario 4: Shoe Retirement and Deletion Cascade**
* **Given** a shoe set as default for a workout type
* **When** the shoe is retired or deleted
* **Then** the default mapping is automatically removed so retired shoes never linger as default workout shoes.

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Create `WorkoutDefaults` table in Drift with `workoutType` (PK) and `shoeId` (FK with cascade delete), increment schema version to 3 with migration.
* [x] `[TASK-02]` Implement Drift queries `watchWorkoutDefaults()`, `getDefaultForWorkoutType()`, `setWorkoutDefault()`, and `removeWorkoutDefaultForShoe()`.
* [x] `[TASK-03]` Add `workoutDefaultsProvider` and `defaultShoeMapProvider` to Riverpod.
* [x] `[TASK-04]` Add "DEFAULT WORKOUT SHOES" section in `SettingsScreen` with selection bottom sheet.
* [x] `[TASK-05]` Enhance `ActivityCardWidget` with 1-tap "Assign to Default ([Shoe Name])" button and prioritized default chip.
* [x] `[TASK-06]` Add default workout badges to `ShoeCardWidget` and `ShoeDetailScreen` with interactive toggle sheet.
* [x] `[TEST-01]` Unit Tests: Test `WorkoutDefaults` CRUD and auto-clear on retirement/deletion in `test/database_test.dart`.
* [x] `[TEST-02]` Widget Tests: Verify Settings defaults picker, 1-tap fast assign, badges, and toggle sheets in `test/workout_defaults_test.dart`.

### `[STORY-10]` Unit Toggle (Miles vs. Kilometers)

* **Parent**: `[EPIC-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-05]`, `[STORY-06]`

**User Story**:

* **As a** runner who logs runs using kilometers instead of miles,
* **I want** to toggle my distance unit preference between Miles (`mi`) and Kilometers (`km`) in Settings,
* **So that** all workout distances, paces, shoe lifespans, remaining mileage, cost-per-distance metrics, dialog presets, and native iOS push notifications reflect my preferred metric without corrupting existing database history.

**Acceptance Criteria**:

* **Scenario 1: Canonical Database Storage with Dynamic Presentation Conversion**
  * **Given** shoes and workouts stored in Drift SQLite
  * **When** distances are recorded or read
  * **Then** distances are canonically stored in miles in SQLite. All UI labels, values, pace strings, and cost-per-unit metrics dynamically convert at the presentation boundary via `UnitFormatter`.

* **Scenario 2: Settings Screen Unit Toggle**
  * **Given** the Settings tab
  * **When** viewing the "UNITS & DISPLAY" section
  * **Then** a SegmentedButton allows switching between `Miles (mi)` and `Kilometers (km)`. Changing the selection writes `distance_unit` to the Drift `AppSettings` table and synchronizes to the shared `UserDefaults` App Group.

* **Scenario 3: Reactive UI Updates Across Entire App**
  * **Given** the user toggles the unit to Kilometers
  * **When** viewing the Garage roster, Nursing Home, Activities (Inbox & History), or Shoe Detail Screen
  * **Then** all distances (e.g., `8.05 km` for a 5.0 mi workout), paces (`4:58 /km`), remaining lifespans (`160.9 / 644 km`), cost-per-unit (`$0.99 /km`), and career stats immediately update.

* **Scenario 4: Unit-Aware Inputs & Dialog Presets**
  * **Given** adding a new shoe, editing a shoe, adding mileage manually, or un-retiring a shoe
  * **When** entering values or tapping preset chips (e.g., `+5.0 km`, `+10.0 km`)
  * **Then** inputs are interpreted in the active unit and converted to canonical miles before saving to SQLite.

* **Scenario 5: Native iOS Push Notification Formatting**
  * **Given** a new HealthKit workout detected in native Swift background execution
  * **When** a push notification is scheduled
  * **Then** the notification body uses the App Group `distance_unit` preference (e.g. `8.05 km` vs `5.00 miles`).

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Create `AppSettings` key-value table in Drift, bump schema version to 4 with migration, and add `getSetting()`, `watchSetting()`, `setSetting()`.
* [x] `[TASK-02]` Implement `UnitFormatter` with full conversion math, pace calculation, cost-per-unit, and label helpers.
* [x] `[TASK-03]` Add `distanceUnitSettingProvider` and `unitPreferenceProvider` in Riverpod.
* [x] `[TASK-04]` Sync unit preference to iOS shared `UserDefaults` via `AppGroupService.syncDistanceUnit()` and update `NotificationManager.swift`.
* [x] `[TASK-05]` Add Units & Display toggle card in `SettingsScreen`.
* [x] `[TASK-06]` Integrate `UnitFormatter` across `ShoeCardWidget`, `ShoeDetailScreen`, `ActivityCardWidget`, `AssignedActivityCard`, `ReassignShoeSheet`, `AddShoeSheet`, and `EditShoeSheet`.
* [x] `[TEST-01]` Unit Tests: Test `UnitFormatter` math, pace, cost-per-unit, and parsing in `test/unit_formatter_test.dart`.
* [x] `[TEST-02]` Unit Tests: Test `AppSettings` get/set/watch in `test/database_test.dart`.
* [x] `[TEST-03]` Widget Tests: Verify Settings toggle, reactive label formatting, and input conversions in `test/unit_toggle_test.dart`.

### `[STORY-11]` Rotation Analytics & Retirement Projections

* **Parent**: `[EPIC-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-06]`, `[STORY-10]`

**User Story**:

* **As a** dedicated runner maintaining a quiver of running shoes,
* **I want** to see analytics on my rotation distribution and accurate retirement projections based on recent usage,
* **So that** I know when each pair needs replacing and can balance mileage across daily trainers, racers, and trail shoes.

**Acceptance Criteria**:

* **Scenario 1: Rotation Analytics Screen Navigation**
  * **Given** the user is on the Garage tab or the Settings tab
  * **When** tapping the insights button in the Garage AppBar or the "Rotation Analytics & Projections" tile in Settings
  * **Then** the app navigates to `RotationAnalyticsScreen` displaying a high-level summary (total active distance, active count, top workhorse shoe, shoes nearing retirement).

* **Scenario 2: Mileage Share & Category Breakdown**
  * **Given** a user with active shoes and assigned activities
  * **When** viewing `RotationAnalyticsScreen`
  * **Then** each active shoe is displayed with its thumbnail, name, percentage of total rotation mileage, and distance bar.
  * **And** a category breakdown shows distribution across Road, Trail, Racing, Track, and Walking shoes.

* **Scenario 3: Predictive Retirement Date & Wear Rate Calculation**
  * **Given** an active shoe with activities recorded in the last 30 days
  * **When** calculating projections via `RotationAnalyticsCalculator`
  * **Then** the wear velocity is calculated as `(milesInLast30Days / 30) * 7` miles/week.
  * **And** estimated weeks remaining is calculated as `remainingMiles / weeklyRate`, producing a projected calendar retirement date (e.g., `Nov 2026`).

* **Scenario 4: Urgency Badges & Shoe Detail Projection Card**
  * **Given** shoes in various stages of lifespan
  * **When** inspecting projections in `RotationAnalyticsScreen` or opening `ShoeDetailScreen`
  * **Then** a colored urgency badge is rendered:
    * `DUE` (Red) if 100%+ lifespan reached
    * `RETIRING SOON` (Deep Orange) if >= 90% lifespan
    * `APPROACHING` (Amber) if >= 75% lifespan
    * `HEALTHY` (Green) if < 75% lifespan
    * `IDLE` (Grey) if no runs recorded in the last 30 days
  * **And** tapping a shoe card in analytics navigates directly to its `ShoeDetailScreen`.

* **Scenario 5: Full Unit Toggle Responsiveness**
  * **Given** the user switches between Miles and Kilometers
  * **When** viewing rotation analytics or retirement projection cards
  * **Then** all weekly rates (`mi/wk` vs `km/wk`), remaining distances, and rotation totals update reactively.

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Create `RotationAnalyticsCalculator` pure Dart logic engine with wear velocity, projected retirement date, urgency status, and category breakdown in `lib/core/utils/rotation_analytics_calculator.dart`.
* [x] `[TASK-02]` Add `rotationAnalyticsProvider` and `shoeProjectionProvider` in `lib/data/providers.dart`.
* [x] `[TASK-03]` Build `RotationAnalyticsScreen` with empty state, rotation summary, mileage share cards, category chips, and urgency-ranked projection cards in `lib/features/garage/screens/rotation_analytics_screen.dart`.
* [x] `[TASK-04]` Add entry point icon to `GarageScreen` AppBar and shortcut tile in `SettingsScreen`.
* [x] `[TASK-05]` Add dedicated `Retirement Projection` card to `ShoeDetailScreen`.
* [x] `[TEST-01]` Unit Tests: Test `RotationAnalyticsCalculator` math, velocity, zero wear rate, urgency thresholds, and unit formatting in `test/rotation_analytics_test.dart` (3 tests passed).
* [x] `[TEST-02]` Widget Tests: Verify empty state, full screen rendering, settings navigation, and shoe detail projection card in `test/rotation_analytics_screen_test.dart` (4 tests passed).
* [x] `[TEST-03]` Integration & Regression: Verify entire test suite passes without regressions (77/77 tests passed across 18 test files).

### `[UI-01]` Performance Studio UI & Tactile Psychology Overhaul

* **Parent**: `[EPIC-02]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[STORY-11]`

**User Story**:

* **As a** dedicated runner maintaining my shoe rotation,
* **I want** the app to feel like an Apple Design Award-winning studio tool with velvety OLED graphite surfaces, athletic neon accents, spring physics, and sensory iOS haptics,
* **So that** tracking and managing my shoes feels premium, tactile, and exhilarating every time I complete a run.

**Acceptance Criteria**:

* **Scenario 1: Performance Studio Palette & OLED Dark Mode**
  * **Given** the app launches
  * **When** viewing any screen
  * **Then** the background is pitch velvety graphite (`#0C0D12`), cards are elevated dark graphite (`#141720`) with 1.0px subtle borders (`#282D3D`), and accents pop in high-energy Electric Volt (`#D4FF00`), Hyper Orange (`#FF5722`), and Cyan Pulse (`#00E5FF`).

* **Scenario 2: Floating Frosted Glass Dock**
  * **Given** the main navigation screen
  * **When** navigating between Garage, Activities, and Settings
  * **Then** a floating translucent blur dock (`FloatingFrostedDock`) floats smoothly above the bottom safe area with pill indicator glows, notification badge counts, and tactile selection clicks (`AppHaptics.selection()`).

* **Scenario 3: Athletic Spec Card & Pressable Physics**
  * **Given** any shoe in the Garage roster
  * **When** interacting with or tapping `ShoeCardWidget`
  * **Then** the card compresses subtly with spring physics (`PressableScale` scale: `0.975`) and triggers a gentle haptic pulse (`AppHaptics.light()`).
  * **And** the lifespan section features an elevated telemetry fuel gauge with remaining mileage readout and color transitions.

* **Scenario 4: Tactile Run Assignment & Inbox Zero Celebration**
  * **Given** the Activities Inbox
  * **When** assigning a workout to a default shoe or tapping any shoe chip
  * **Then** a satisfying medium impact haptic pulse fires (`AppHaptics.medium()`).
  * **And** when all runs are assigned, a celebratory "All Caught Up! 🎉" glowing sync badge appears.

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Create `AppColors` palette and `AppTheme` with `ThemeData.dark()` / `light()` in `lib/core/theme/`.
* [x] `[TASK-02]` Build `AppHaptics` centralized iOS haptic feedback engine in `lib/core/theme/app_haptics.dart`.
* [x] `[TASK-03]` Build `PressableScale` spring-physics tactile tap wrapper in `lib/core/widgets/pressable_scale.dart`.
* [x] `[TASK-04]` Build `FloatingFrostedDock` frosted glass navigation bar in `lib/core/widgets/floating_frosted_dock.dart`.
* [x] `[TASK-05]` Elevate `ShoeCardWidget` to an Athletic Spec Card with telemetry fuel gauge and press physics in `lib/features/garage/widgets/shoe_card_widget.dart`.
* [x] `[TASK-06]` Elevate `ActivityCardWidget`, `UnassignedRunCarousel`, and `AssignedActivityCard` with telemetry strips, haptic snaps, and celebratory inbox-zero state.
* [x] `[TEST-01]` Full Test Suite Regression: Verify all 77 tests pass without failures (77/77 passed across 18 test files).
* [x] `[TEST-02]` Static Analysis: Verify `flutter analyze` reports 0 issues.

### `[RELEASE-01]` App Store Production Assets, Website & Bundle ID

* **Parent**: `[EPIC-01]`
* **Complexity**: M (5 pts)
* **Dependencies**: `[UI-01]`

**User Story**:

* **As a** developer preparing for public App Store distribution,
* **I want** a production-ready 1024x1024 app icon, complete iOS asset catalog, updated bundle identifier (`com.shoegarage.app`), and a dedicated public website with HealthKit-compliant Privacy Policy and Terms of Service,
* **So that** the app meets all Apple App Store Review Guidelines (Guideline 5.1.1 and 5.1.3) and is ready for App Store Connect submission.

**Acceptance Criteria**:

* **Scenario 1: Dedicated Website & Legal Compliance**
  * **Given** Apple requires active public Support and Privacy Policy URLs
  * **When** accessing the static site in `docs/`
  * **Then** `docs/index.html` showcases app features, FAQ, and support contact (`support@shoegarage.app`).
  * **And** `docs/privacy.html` strictly declares read-only HealthKit data access solely for on-device shoe mileage, explicitly disclaims advertising/data broker sales, and documents local encrypted SQLite storage.
  * **And** `docs/terms.html` establishes non-medical mileage estimation disclaimers.

* **Scenario 2: Production App Icon & Asset Catalog**
  * **Given** an Apple Design Award aesthetic
  * **When** building for iOS
  * **Then** a 1024x1024 master app icon (`assets/icon/app_icon.png`) is generated with glowing Electric Volt and Hyper Orange aerodynamic shoe geometry on pitch-black OLED background.
  * **And** all 15 required iOS icon scales in `ios/Runner/Assets.xcassets/AppIcon.appiconset/` are generated and verified.

* **Scenario 3: Production Bundle Identifier**
  * **Given** Xcode project configuration
  * **When** inspecting `project.pbxproj`
  * **Then** `PRODUCT_BUNDLE_IDENTIFIER` across Debug, Profile, and Release is updated to `com.shoegarage.app` (and `com.shoegarage.app.RunnerTests`).

**Technical Tasks & Test Cases**:

* [x] `[TASK-01]` Generate master 1024x1024 app icon (`assets/icon/app_icon.png`).
* [x] `[TASK-02]` Generate all 15 icon sizes inside `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.
* [x] `[TASK-03]` Create dedicated website with `index.html`, `privacy.html`, `terms.html`, and `style.css` in `docs/`.
* [x] `[TASK-04]` Update `PRODUCT_BUNDLE_IDENTIFIER` to `com.shoegarage.app` in `ios/Runner.xcodeproj/project.pbxproj`.
* [x] `[TASK-05]` Verify clean compilation and launch on simulator (`com.shoegarage.app: 30855`).
* [x] `[TEST-01]` Full Test Suite Regression: All 77 unit & widget tests pass (77/77 passed across 18 test files).
* [x] `[TEST-02]` Static Analysis: `flutter analyze` reports 0 issues.

## 4. Quality Gates & Sign-Off

### Definition of Ready (DoR)

* [x] Ambiguities resolved and architectural dependencies mapped
* [x] Stories vertically sliced and sized under XL (8 pts)
* [x] Acceptance criteria defined in Given/When/Then format

### Definition of Done (DoD)

* [x] All `[TASK-XX]` implementation steps completed
* [x] All `[TEST-XX]` unit and integration tests written and passing (77/77 passed across 18 test files)
* [x] Type safety, linting, and error handling verified (`flutter analyze`: 0 issues)
* [x] Native build verified (`flutter build ios --simulator --no-codesign`: Success in 13.7s)
* [x] App installed and running on iPhone 16 Simulator under `com.shoegarage.app` (PID: 30855)

---



