import Foundation
import HealthKit
import Flutter

public class HealthKitManager {
    public static let shared = HealthKitManager()
    
    public let healthStore = HKHealthStore()
    private var workoutObserverQuery: HKObserverQuery?
    
    // Callback when new workout is detected via background observer
    public var onWorkoutDetected: ((HKWorkout) -> Void)?
    
    // Track if observer has been started
    public private(set) var isObserverRunning = false
    
    private init() {}
    
    public func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.shoegarage/health_kit", binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isHealthDataAvailable":
            result(HKHealthStore.isHealthDataAvailable())
            
        case "requestAuthorization":
            requestAuthorization { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "AUTH_ERROR", message: error.localizedDescription, details: nil))
                    } else {
                        result(success)
                    }
                }
            }
            
        case "startObserver":
            startWorkoutObserverQuery()
            result(true)
            
        case "fetchRecentWorkouts":
            let args = call.arguments as? [String: Any]
            let days = args?["days"] as? Int ?? 30
            fetchRecentWorkouts(days: days) { workouts, error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
                    } else {
                        let serialized = workouts.map { self.serializeWorkout($0) }
                        result(serialized)
                    }
                }
            }
            
        case "fetchAnchoredWorkouts":
            fetchAnchoredWorkouts { workouts, error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
                    } else {
                        let serialized = workouts.map { self.serializeWorkout($0) }
                        result(serialized)
                    }
                }
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Requests HealthKit read permissions for workouts and running/walking distance.
    public func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        var readTypes: Set<HKObjectType> = [
            HKObjectType.workoutType()
        ]
        
        if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            readTypes.insert(distanceType)
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] (success, error) in
            if success {
                NSLog("[ShoeGarage] HealthKit authorization granted. Initializing background observer.")
                self?.startWorkoutObserverQuery()
                self?.enableBackgroundDelivery()
            } else if let error = error {
                NSLog("[ShoeGarage] HealthKit authorization failed: \(error.localizedDescription)")
            }
            completion(success, error)
        }
    }
    
    /// Sets up HKObserverQuery with .immediate delivery frequency for background execution.
    public func startWorkoutObserverQuery() {
        guard HKHealthStore.isHealthDataAvailable() else {
            NSLog("[ShoeGarage] HealthKit unavailable, skipping observer query.")
            return
        }
        
        if workoutObserverQuery != nil {
            NSLog("[ShoeGarage] Workout observer query is already active.")
            return
        }
        
        let sampleType = HKObjectType.workoutType()
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] (query, completionHandler, error) in
            if let error = error {
                NSLog("[ShoeGarage] HKObserverQuery received error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            NSLog("[ShoeGarage] HKObserverQuery woke in background for workout update.")
            self?.handleBackgroundWorkoutUpdate(completionHandler: completionHandler)
        }
        
        healthStore.execute(query)
        workoutObserverQuery = query
        isObserverRunning = true
        enableBackgroundDelivery()
        NSLog("[ShoeGarage] HKObserverQuery executed and running.")
    }
    
    /// Enables immediate background delivery frequency for workout types.
    public func enableBackgroundDelivery() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let sampleType = HKObjectType.workoutType()
        healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (success, error) in
            if let error = error {
                NSLog("[ShoeGarage] Failed to enable background delivery: \(error.localizedDescription)")
            } else {
                NSLog("[ShoeGarage] Immediate background delivery successfully enabled: \(success)")
            }
        }
    }
    
    /// Handles observer query callback by fetching the newest workout and triggering listeners.
    public func handleBackgroundWorkoutUpdate(completionHandler: @escaping () -> Void) {
        // Query the most recent workout finished within the last 2 hours
        let now = Date()
        let twoHoursAgo = now.addingTimeInterval(-7200)
        let predicate = HKQuery.predicateForSamples(withStart: twoHoursAgo, end: now, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(
            sampleType: HKObjectType.workoutType(),
            predicate: predicate,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] (query, samples, error) in
            defer { completionHandler() }
            
            if let error = error {
                NSLog("[ShoeGarage] Error querying recent workout in background: \(error.localizedDescription)")
                return
            }
            
            guard let workouts = samples as? [HKWorkout], let latestWorkout = workouts.first else {
                NSLog("[ShoeGarage] No recent workout found matching window.")
                return
            }
            
            NSLog("[ShoeGarage] Background workout detected: \(latestWorkout.uuid.uuidString)")
            self?.onWorkoutDetected?(latestWorkout)
            
            let distanceInMiles = latestWorkout.totalDistance?.doubleValue(for: HKUnit.mile()) ?? 0.0
            var workoutTypeStr = "running"
            switch latestWorkout.workoutActivityType {
            case .running:
                workoutTypeStr = "running"
            case .walking:
                workoutTypeStr = "walking"
            case .hiking:
                workoutTypeStr = "hiking"
            default:
                workoutTypeStr = "workout"
            }
            NotificationManager.shared.postWorkoutNotification(
                workoutId: latestWorkout.uuid.uuidString,
                workoutType: workoutTypeStr,
                distance: distanceInMiles
            )
        }
        
        healthStore.execute(sampleQuery)
    }
    
    /// Fetches historical workouts within the last N days.
    public func fetchRecentWorkouts(days: Int, completion: @escaping ([HKWorkout], Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion([], NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit unavailable"]))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate.addingTimeInterval(-TimeInterval(days * 86400))
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: HKObjectType.workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in
            if let error = error {
                completion([], error)
                return
            }
            
            let workouts = (samples as? [HKWorkout]) ?? []
            completion(workouts, nil)
        }
        
        healthStore.execute(query)
    }
    
    private let anchorKey = "HKWorkoutAnchorKey"
    
    /// Fetches workouts using HKAnchoredObjectQuery to incrementally retrieve new and updated workouts.
    public func fetchAnchoredWorkouts(completion: @escaping ([HKWorkout], Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion([], NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit unavailable"]))
            return
        }
        
        var anchor: HKQueryAnchor? = nil
        if let anchorData = UserDefaults.standard.data(forKey: anchorKey) {
            anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData)
        }
        
        let sampleType = HKObjectType.workoutType()
        let query = HKAnchoredObjectQuery(
            type: sampleType,
            predicate: nil,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] (query, samples, deletedObjects, newAnchor, error) in
            if let error = error {
                completion([], error)
                return
            }
            
            if let newAnchor = newAnchor {
                if let encoded = try? NSKeyedArchiver.archivedData(withRootObject: newAnchor, requiringSecureCoding: true) {
                    UserDefaults.standard.set(encoded, forKey: self?.anchorKey ?? "HKWorkoutAnchorKey")
                }
            }
            
            let workouts = (samples as? [HKWorkout]) ?? []
            completion(workouts, nil)
        }
        
        healthStore.execute(query)
    }
    
    /// Serializes an HKWorkout to a JSON-compatible dictionary.
    public func serializeWorkout(_ workout: HKWorkout) -> [String: Any] {
        let distanceInMiles: Double
        if let totalDistance = workout.totalDistance {
            distanceInMiles = totalDistance.doubleValue(for: HKUnit.mile())
        } else {
            distanceInMiles = 0.0
        }
        
        let isoFormatter = ISO8601DateFormatter()
        
        var workoutTypeStr = "running"
        switch workout.workoutActivityType {
        case .running:
            workoutTypeStr = "running"
        case .walking:
            workoutTypeStr = "walking"
        case .hiking:
            workoutTypeStr = "hiking"
        default:
            workoutTypeStr = "other"
        }
        
        var dict: [String: Any] = [
            "workoutId": workout.uuid.uuidString,
            "workoutType": workoutTypeStr,
            "distance": distanceInMiles,
            "duration": workout.duration,
            "startDate": isoFormatter.string(from: workout.startDate),
            "endDate": isoFormatter.string(from: workout.endDate),
            "source": workout.sourceRevision.source.name,
            "sourceBundleId": workout.sourceRevision.source.bundleIdentifier
        ]
        
        return dict
    }
}
