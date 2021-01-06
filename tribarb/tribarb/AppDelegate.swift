// Swift
//
// AppDelegate.swift

import UIKit
import FBSDKCoreKit
import Stripe
import PushNotifications

let pushNotifications = PushNotifications.shared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Stripe.setDefaultPublishableKey("pk_test_51GwZcgJGRtokdLfWGTP34rmIWR1Rzqb2rx7KruKurcBeRD6mglqetEFuUdRwCdLNtm93siuUqtgV24mvS3yDcHdG00Mvjovux2")
        STPPaymentConfiguration.shared().appleMerchantIdentifier = "merchant.com.tribarb"
        
        //FB
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }
    
    
    //FB
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotifications.registerDeviceToken(deviceToken)
    }

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushNotifications.handleNotification(userInfo: userInfo)
    }
          
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        APIManager.shared.logout { (error) in
            if error != nil {
                print("Unable to logout.")
            }
        }
        sleep(3)
    }
}


