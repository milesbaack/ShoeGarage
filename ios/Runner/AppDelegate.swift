import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let registrar = self.registrar(forPlugin: "AppGroupBridge") {
      AppGroupBridge.shared.register(with: registrar)
    }
    if let healthKitRegistrar = self.registrar(forPlugin: "HealthKitManager") {
      HealthKitManager.shared.register(with: healthKitRegistrar)
    }
    if let notificationRegistrar = self.registrar(forPlugin: "NotificationManager") {
      NotificationManager.shared.register(with: notificationRegistrar)
    }
    HealthKitManager.shared.startWorkoutObserverQuery()
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
