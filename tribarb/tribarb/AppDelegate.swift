// Swift
//
// AppDelegate.swift

import UIKit
import FBSDKCoreKit
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {

    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
          
        Stripe.setDefaultPublishableKey("pk_test_51GwZcgJGRtokdLfWGTP34rmIWR1Rzqb2rx7KruKurcBeRD6mglqetEFuUdRwCdLNtm93siuUqtgV24mvS3yDcHdG00Mvjovux2")
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }
          
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


// Class for text fields
//import Foundation

//class CustomTextField:UITextField{
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setProperties()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setProperties()
//    }
//
//    func setProperties(){
//
//        backgroundColor = UIColor.white
//        textAlignment = .left
//        textColor = .black
//        font = UIFont.systemFont(ofSize: 15)
//        layer.borderWidth = 1.0
//        layer.cornerRadius = 5
//        if let placeholder = self.placeholder {
//            self.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//        }
//    }
//}

