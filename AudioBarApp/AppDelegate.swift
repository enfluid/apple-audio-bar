import UIKit
import AVFoundation

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        try! AVAudioSession.sharedInstance().setMode(AVAudioSessionModeSpokenAudio)
        try! AVAudioSession.sharedInstance().setActive(true)

        return true

    }

}
