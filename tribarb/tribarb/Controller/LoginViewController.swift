//
//  LoginViewController.swift
//  tribarb
//
//  Created by Anith Manu on 22/10/2020.
//

import UIKit
import FBSDKLoginKit


class LoginViewController: UIViewController {
    
    
    var fbLoginSuccess = false
    var userType: String = USERTYPE_CUSTOMER

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (AccessToken.current != nil ) {
            FBManager.getFBUserData {
                APIManager.shared.login(userType: self.userType) { (error) in
                    if error == nil {
                        self.fbLoginSuccess = true
                        self.viewDidAppear(true)
                    }
                }
            }
        }

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (AccessToken.current != nil){
            performSegue(withIdentifier: "CustomerView", sender: self)
        }
      
    }
    
    
    
    @IBAction func facebookLogin(_ sender: Any) {
        FBManager.shared.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if (error == nil) {
                
                FBManager.getFBUserData {
                    APIManager.shared.login(userType: self.userType) { (error) in
                        if error == nil {
                            self.fbLoginSuccess = true
                            self.viewDidAppear(true)
                        }
                    }
                }
            }
        }

    }
    
    
    
    
    
    
    
    
    
    
    
}





