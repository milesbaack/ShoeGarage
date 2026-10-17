import Flutter
import UIKit
import XCTest
import HealthKit
import UserNotifications
@testable import Runner

class RunnerTests: XCTestCase {

  func testAppGroupBridgeUserDefaults() {
    let bridge = AppGroupBridge.shared
    
    // Test active shoes serialization
    let testJson = "[{\"id\":\"shoe-1\",\"name\":\"Hoka Clifton 9\"}]"
    bridge.saveActiveShoes(testJson)
    XCTAssertEqual(bridge.getActiveShoesJson(), testJson)
    
    // Test pending assignments queue
    bridge.clearPendingAssignments()
    XCTAssertEqual(bridge.getPendingAssignments().count, 0)
    
    bridge.appendPendingAssignment(workoutId: "workout-100", shoeId: "shoe-1")
    let assignments = bridge.getPendingAssignments()
    XCTAssertEqual(assignments.count, 1)
    XCTAssertEqual(assignments.first?["workoutId"] as? String, "workout-100")
    XCTAssertEqual(assignments.first?["shoeId"] as? String, "shoe-1")
    
    bridge.clearPendingAssignments()
    XCTAssertEqual(bridge.getPendingAssignments().count, 0)
  }

  func testHealthKitManagerInstanceAndObserver() {
    let manager = HealthKitManager.shared
    XCTAssertNotNil(manager.healthStore)
    
    // Verify callback triggers when workout is detected
    var detectedWorkoutUUID: String?
    manager.onWorkoutDetected = { workout in
      detectedWorkoutUUID = workout.uuid.uuidString
    }
    
    // Mock workout object
    let now = Date()
    let workout = HKWorkout(
      activityType: .running,
      start: now.addingTimeInterval(-1800),
      end: now,
      duration: 1800,
      totalEnergyBurned: nil,
      totalDistance: HKQuantity(unit: .mile(), doubleValue: 3.5),
      metadata: nil
    )
    
    manager.onWorkoutDetected?(workout)
    XCTAssertEqual(detectedWorkoutUUID, workout.uuid.uuidString)
    
    // Verify workout serialization
    let serialized = manager.serializeWorkout(workout)
    XCTAssertEqual(serialized["workoutType"] as? String, "running")
    XCTAssertEqual(serialized["distance"] as? Double, 3.5)
    XCTAssertEqual(serialized["duration"] as? Double, 1800)
  }

  func testNotificationManagerActionProcessing() {
    let notificationMgr = NotificationManager.shared
    
    // Test valid shoe action
    let actionId = "\(NotificationManager.actionPrefix)shoe-hoka-1"
    let userInfo: [AnyHashable: Any] = ["workoutId": "hk-workout-777", "workoutType": "running"]
    
    let result = notificationMgr.processNotificationAction(actionIdentifier: actionId, userInfo: userInfo)
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.workoutId, "hk-workout-777")
    XCTAssertEqual(result?.shoeId, "shoe-hoka-1")
    
    // Test dismiss action (should not trigger assignment)
    let dismissResult = notificationMgr.processNotificationAction(
      actionIdentifier: UNNotificationDismissActionIdentifier,
      userInfo: userInfo
    )
    XCTAssertNil(dismissResult)
  }

}
