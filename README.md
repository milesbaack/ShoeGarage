## 1. Architecture & Dependency Overview

* **Core Objective**: Develop an iOS app to automatically track shoe mileage by passively syncing Apple Health workouts and allowing users to assign mileage via interactive push notifications.
* **Key Assumptions**: The user is targeting iOS 16+ (using modern Swift concurrency and HealthKit APIs). CloudKit quota limits are sufficient for user data and shoe image syncing without requiring a dedicated backend.
* **State & Data Migrations**: Initial setup requires scaffolding a Drift (SQLite) database with `Shoes` and `Activities` tables, alongside a `UserDefaults` App Group suite for the native Swift notification bridge. A migration path from zero state to populated state via an initial 30-day HealthKit sync is required.
* **Critical Bottlenecks & Risks**: Apple App Store Review (requires explicit `NSHealthShareUsageDescription` justification and safe background execution limits). Background execution reliability (relying on `HKObserverQuery` and `UserDefaults` instead of waking the Flutter engine). Overlapping workout deduplication logic.

## 2. Sprint Roadmap Table

| ID | Item | Estimated Complexity | Dependencies | Status |
| --- | --- | --- | --- | --- |
| `[EPIC-01]` | Foundation & Native Architecture | - | None | Planned |
| `[EPIC-02]` | UI Structure & State Management | - | `[EPIC-01]` | Planned |
| `[FEAT-01]` | Background HealthKit Observer Pipeline | - | `[EPIC-01]` | Planned |
| `[FEAT-02]` | Local Persistence & Cloud Backup | - | `[EPIC-01]` | Planned |
| `[ENABLER-01]` | Scaffold Drift Schema & App Group Setup | S (2 pts) | None | Ready |
| `[ENABLER-02]` | Implement Native Swift HKObserverQuery | M (5 pts) | `[ENABLER-01]` | Planned |
| `[STORY-01]` | Background Workout Notification & Queueing | M (5 pts) | `[ENABLER-02]` | Blocked |
| `[STORY-02]` | Initial 30-Day HealthKit Sync & Deduplication | L (8 pts) | `[ENABLER-01]` | Blocked |
| `[STORY-03]` | Garage Tab: Shoe Roster & Battery Life UI | M (3 pts) | `[ENABLER-01]` | Blocked |
| `[STORY-04]` | Activity Tab: Unassigned Run Carousel | M (5 pts) | `[STORY-01]`, `[STORY-02]` | Blocked |

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

* [ ] `[TASK-01]` Create `database.dart` defining `Shoes` and `Activities` classes.
* [ ] `[TASK-02]` Generate Drift schema files.
* [ ] `[TASK-03]` Configure iOS App Group in Xcode to allow shared `UserDefaults` access.
* [ ] `[TEST-01]` Unit Test: Verify Drift database table creation and basic CRUD operations.

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

* [ ] `[TASK-01]` Request HealthKit permissions in Flutter and handle OS-level authorization.
* [ ] `[TASK-02]` Write `HKObserverQuery` setup inside `AppDelegate.swift` with `.immediate` background delivery frequency.
* [ ] `[TEST-01]` Integration Test: Mock a completed HealthKit workout and verify the background observer fires.

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

* [ ] `[TASK-01]` Configure `UNUserNotificationCenter` categories and actions dynamically based on `UserDefaults` shoe data.
* [ ] `[TASK-02]` Handle notification action responses in Swift to push data to the queue.
* [ ] `[TASK-03]` Implement Riverpod listener on app foreground to read, execute, and clear the `UserDefaults` queue into Drift.
* [ ] `[TEST-01]` Integration Test: Verify tapping a notification action successfully updates the Drift database upon next app launch.

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

* [ ] `[TASK-01]` Implement `HKAnchoredObjectQuery` in Swift/Flutter to fetch historical data.
* [ ] `[TASK-02]` Implement the 2-hour stale check to suppress notifications during bulk syncs.
* [ ] `[TASK-03]` Write the 80% overlap deduplication logic before inserting into Drift.
* [ ] `[TEST-01]` Unit Test: Feed two overlapping workout objects into the deduplication function and ensure only one is preserved.

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

* [ ] `[TASK-01]` Build the Riverpod provider to stream `isRetired == false` shoes from Drift.
* [ ] `[TASK-02]` Create the `ShoeCardWidget` featuring custom layout, photo support, and the linear progress bar.
* [ ] `[TASK-03]` Implement the "Retire" logic ensuring the target distance snap behavior.
* [ ] `[TEST-01]` UI Test: Verify the progress bar color changes to a warning state when >90% complete.

## 4. Quality Gates & Sign-Off

### Definition of Ready (DoR)

* [x] Ambiguities resolved and architectural dependencies mapped
* [x] Stories vertically sliced and sized under XL (8 pts)
* [x] Acceptance criteria defined in Given/When/Then format

### Definition of Done (DoD)

* [ ] All `[TASK-XX]` implementation steps completed
* [ ] All `[TEST-XX]` unit and integration tests written and passing
* [ ] Type safety, linting, and error handling verified

---

**STOP - Awaiting Sign-Off**: I have paused before writing any code. Please review this development plan. Reply with adjustments, or tell me which ticket to implement first (for example, `"Approved, start [ENABLER-01]"`).
