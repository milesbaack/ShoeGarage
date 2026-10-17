import Foundation
import UserNotifications
import Flutter

public class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    public static let categoryIdentifier = "WORKOUT_ASSIGNMENT_CATEGORY"
    public static let actionPrefix = "ASSIGN_SHOE_"
    
    private override init() {
        super.init()
    }
    
    public func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.shoegarage/notifications", binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestPermissions":
            requestAuthorization { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "NOTIFICATION_AUTH_ERROR", message: error.localizedDescription, details: nil))
                    } else {
                        result(granted)
                    }
                }
            }
            
        case "updateCategories":
            updateNotificationCategories()
            result(true)
            
        case "postTestNotification":
            guard let args = call.arguments as? [String: Any],
                  let workoutId = args["workoutId"] as? String,
                  let workoutType = args["workoutType"] as? String,
                  let distance = args["distance"] as? Double else {
                result(FlutterError(code: "INVALID_ARGS", message: "workoutId, workoutType, and distance required", details: nil))
                return
            }
            postWorkoutNotification(workoutId: workoutId, workoutType: workoutType, distance: distance)
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Request notification authorization for alerts, sounds, and badges.
    public func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted, error) in
            if granted {
                NSLog("[ShoeGarage] Notification permission granted. Updating categories.")
                self?.updateNotificationCategories()
            }
            completion(granted, error)
        }
    }
    
    /// Dynamically constructs UNNotificationAction buttons based on active shoes in shared UserDefaults.
    public func updateNotificationCategories() {
        guard let jsonString = AppGroupBridge.shared.getActiveShoesJson(),
              let data = jsonString.data(using: .utf8),
              let shoes = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            NSLog("[ShoeGarage] No active shoes found for notification categories.")
            return
        }
        
        var actions: [UNNotificationAction] = []
        
        // iOS supports displaying up to 4 quick actions in expanded notifications
        let candidateShoes = Array(shoes.prefix(4))
        for shoe in candidateShoes {
            guard let id = shoe["id"] as? String,
                  let name = shoe["name"] as? String else { continue }
            
            let actionId = "\(NotificationManager.actionPrefix)\(id)"
            // No options required so users can tap directly on the lockscreen without opening the app
            let action = UNNotificationAction(
                identifier: actionId,
                title: name,
                options: []
            )
            actions.append(action)
        }
        
        let category = UNNotificationCategory(
            identifier: NotificationManager.categoryIdentifier,
            actions: actions,
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        NSLog("[ShoeGarage] Registered \(actions.count) shoe action buttons for notifications.")
    }
    
    /// Fires a local push notification asking which shoe was worn for the completed workout.
    public func postWorkoutNotification(workoutId: String, workoutType: String, distance: Double) {
        // Ensure categories are up to date with the latest active shoes
        updateNotificationCategories()
        
        let content = UNMutableNotificationContent()
        
        let titleEmoji: String
        let formattedType: String
        switch workoutType.lowercased() {
        case "running":
            titleEmoji = "🏃"
            formattedType = "Run"
        case "walking":
            titleEmoji = "🚶"
            formattedType = "Walk"
        case "hiking":
            titleEmoji = "🥾"
            formattedType = "Hike"
        default:
            titleEmoji = "👟"
            formattedType = "Workout"
        }
        
        content.title = "\(formattedType) Finished! \(titleEmoji)"
        let unit = AppGroupBridge.shared.getDistanceUnit()
        if unit == "km" {
            let kmDistance = distance * 1.609344
            content.body = String(format: "You logged %.2f km. Which shoe did you wear?", kmDistance)
        } else {
            content.body = String(format: "You logged %.2f miles. Which shoe did you wear?", distance)
        }
        content.sound = .default
        content.categoryIdentifier = NotificationManager.categoryIdentifier
        content.userInfo = [
            "workoutId": workoutId,
            "workoutType": workoutType,
            "distance": distance
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "workout_notification_\(workoutId)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                NSLog("[ShoeGarage] Error scheduling workout notification: \(error.localizedDescription)")
            } else {
                NSLog("[ShoeGarage] Workout notification posted successfully for \(workoutId).")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Present notification even when the app is in the foreground.
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    /// Handles user tapping an action button or the notification itself.
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionId = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        if let result = processNotificationAction(actionIdentifier: actionId, userInfo: userInfo) {
            NSLog("[ShoeGarage] User selected shoe \(result.shoeId) for workout \(result.workoutId). Appending to queue.")
            AppGroupBridge.shared.appendPendingAssignment(workoutId: result.workoutId, shoeId: result.shoeId)
        }
        
        completionHandler()
    }
    
    /// Parses the action identifier and userInfo payload to extract [workoutId, shoeId].
    public func processNotificationAction(actionIdentifier: String, userInfo: [AnyHashable: Any]) -> (workoutId: String, shoeId: String)? {
        guard actionIdentifier.hasPrefix(NotificationManager.actionPrefix),
              let workoutId = userInfo["workoutId"] as? String else {
            return nil
        }
        
        let shoeId = String(actionIdentifier.dropFirst(NotificationManager.actionPrefix.count))
        guard !shoeId.isEmpty else { return nil }
        
        return (workoutId: workoutId, shoeId: shoeId)
    }
}
