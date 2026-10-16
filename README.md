# Shoe Garage

Shoe Garage is an iOS app built with Flutter and Swift that automatically tracks the mileage on your running shoes. 

Instead of making users manually log every run, the app listens to Apple Health in the background. When you finish a workout, it fires an interactive push notification. You tap the shoe you wore right from the lock screen, and the app updates your local database. 

## How it Works

1. You finish a run (tracked via Apple Watch, Garmin, Strava, etc.).
2. iOS writes the `HKWorkout` to Apple Health.
3. A native Swift background observer (`HKObserverQuery`) wakes up.
4. It sends a push notification featuring your active shoes as buttons.
5. Tapping a button saves the mileage to a queue, which syncs to your local database the next time you open the app.

## Core Features

* **Native Background Execution:** To prevent battery drain and App Store rejections, the background sync bypasses the Flutter engine entirely. Swift handles the HealthKit observation and notifications natively.
* **Contextual Notifications:** The push notification buttons adapt based on the workout type (e.g., showing trail shoes for hikes, road shoes for runs).
* **Mileage Tracking:** Visual progress bars track current mileage against the shoe's target lifespan.
* **The "Nursing Home":** A dedicated graveyard tab to preserve stats and photos of retired shoes.
* **Local First:** 100% on-device SQLite database. It silently mirrors to the user's private CloudKit database for disaster recovery, keeping the app free of backend server costs.

## Tech Stack

* **UI & Logic:** Flutter (iOS 16+ target)
* **State Management:** Riverpod
* **Database:** Drift (SQLite)
* **Native Bridge:** Swift (HealthKit, UserNotifications, App Groups)
* **Cloud Sync:** CloudKit Private Database (with `CKAsset` for local shoe photos)

## 🏃 Getting Started

Because Shoe Garage relies heavily on native iOS background processes and HealthKit, it is exclusively available on the Apple App Store. 

### Installation & Setup

1. **Download:** Get Shoe Garage from the iOS App Store.
2. **Health Permissions:** On your first launch, tap "Allow" when prompted for Apple Health access. *Note: We only read running, walking, and hiking workout data—nothing else.*
3. **Notification Permissions:** Allow push notifications. This is required so the app can ask which shoes you wore right on your lock screen when you finish a run.
4. **Build Your Garage:** Tap the "+" button to add your active shoe rotation. 
5. **Initial Sync (Optional):** Go to Settings and tap "Import Last 30 Days" to instantly populate your recent workout history.
