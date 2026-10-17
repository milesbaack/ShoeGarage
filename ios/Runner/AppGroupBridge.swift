import Foundation
import Flutter

public class AppGroupBridge {
    public static let shared = AppGroupBridge()
    
    public let appGroupId = "group.com.shoegarage.shared"
    public let shoesKey = "active_shoes"
    public let pendingAssignmentsKey = "pending_assignments"
    public let distanceUnitKey = "distance_unit"
    
    public var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupId)
    }
    
    private init() {}
    
    public func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.shoegarage/app_group", binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "saveDistanceUnit":
            guard let args = call.arguments as? [String: Any],
                  let unit = args["unit"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "unit required", details: nil))
                return
            }
            saveDistanceUnit(unit)
            result(true)

        case "getDistanceUnit":
            result(getDistanceUnit())

        case "saveActiveShoes":
            guard let args = call.arguments as? [String: Any],
                  let shoesJson = args["shoesJson"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "shoesJson required", details: nil))
                return
            }
            saveActiveShoes(shoesJson)
            result(true)
            
        case "getActiveShoes":
            result(getActiveShoesJson())
            
        case "getPendingAssignments":
            result(getPendingAssignments())
            
        case "clearPendingAssignments":
            clearPendingAssignments()
            result(true)
            
        case "appendPendingAssignment":
            guard let args = call.arguments as? [String: Any],
                  let workoutId = args["workoutId"] as? String,
                  let shoeId = args["shoeId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "workoutId and shoeId required", details: nil))
                return
            }
            appendPendingAssignment(workoutId: workoutId, shoeId: shoeId)
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func saveDistanceUnit(_ unit: String) {
        userDefaults?.set(unit, forKey: distanceUnitKey)
        userDefaults?.synchronize()
    }

    public func getDistanceUnit() -> String {
        return userDefaults?.string(forKey: distanceUnitKey) ?? "mi"
    }

    public func saveActiveShoes(_ jsonString: String) {
        userDefaults?.set(jsonString, forKey: shoesKey)
        userDefaults?.synchronize()
    }
    
    public func getActiveShoesJson() -> String? {
        return userDefaults?.string(forKey: shoesKey)
    }
    
    public func getPendingAssignments() -> [[String: Any]] {
        return userDefaults?.array(forKey: pendingAssignmentsKey) as? [[String: Any]] ?? []
    }
    
    public func appendPendingAssignment(workoutId: String, shoeId: String) {
        var current = getPendingAssignments()
        let assignment: [String: Any] = [
            "workoutId": workoutId,
            "shoeId": shoeId,
            "timestamp": Date().timeIntervalSince1970
        ]
        current.append(assignment)
        userDefaults?.set(current, forKey: pendingAssignmentsKey)
        userDefaults?.synchronize()
    }
    
    public func clearPendingAssignments() {
        userDefaults?.removeObject(forKey: pendingAssignmentsKey)
        userDefaults?.synchronize()
    }
}
