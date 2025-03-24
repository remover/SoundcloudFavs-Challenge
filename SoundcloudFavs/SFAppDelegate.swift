import SwiftUI
import UIKit

class SFAppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    let clientID = "9089b0b73fd02458609874d04a1cdeda"
    let secret = "5af54e87cb2b4f084bdecdb5e3d6477c"
    let redirectURLStr = "soundcloudfavs://soundcloud"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        SCSoundCloud.removeAccess()
        SCSoundCloud.setClientID(clientID, secret: secret, redirectURL: URL(string: redirectURLStr)!)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Handle application resigning active state
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Handle application entering background state
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Handle application entering foreground state
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Handle application becoming active
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Handle application termination
    }
}
