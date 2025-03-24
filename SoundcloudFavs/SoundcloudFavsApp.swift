import SwiftUI

@main
struct SoundcloudFavsApp: App {
    @UIApplicationDelegateAdaptor(SFAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
