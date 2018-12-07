import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    if (FlutterLinkedinLoginPlugin.shouldHandle(open)) {
           return FlutterLinkedinLoginPlugin.application(app, open: open, sourceApplication: nil, annotation: nil)
       }
       return true
  }
}

