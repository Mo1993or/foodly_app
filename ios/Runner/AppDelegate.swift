
import UIKit
import Flutter
import GoogleMaps
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        FirebaseApp.configure()

        GMSServices.provideAPIKey("AIzaSyBDhN3cbJWJRRgVBtikVjp5o0_r0yO-yns")

        GeneratedPluginRegistrant.register(with: self)

        application.registerForRemoteNotifications()

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    // Réception du token APNs
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken

        let token = deviceToken.map {
            String(format: "%02x", $0)
        }.joined()

        print("APNs TOKEN RECU :")
        print(token)

        super.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )
    }

    // Échec de l'enregistrement APNs
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("ECHEC APNs : \(error.localizedDescription)")

        super.application(
            application,
            didFailToRegisterForRemoteNotificationsWithError: error
        )
    }
}
