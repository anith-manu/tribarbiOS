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
    @IBOutlet weak var switchUser: UISegmentedControl!
    @IBOutlet weak var userTypeImage: UIImageView!

    
    
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
        if (AccessToken.current != nil) {
            APIManager.shared.getLastLoggedInAs { (json) in
                if json != nil {
                    if json!["last_logged_in_as"] ==  "customer" {
                        self.performSegue(withIdentifier: "CustomerView", sender: self)
                    } else if json!["last_logged_in_as"] ==  "employee" {
                        if json!["verified"] == false {
                            self.performSegue(withIdentifier: "EmployeeVerification", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "EmployeeView", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func facebookLogin(_ sender: Any) {
        FBManager.shared.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if (error == nil) {
                
                FBManager.getFBUserData {
                    APIManager.shared.login(userType: self.userType) { (error) in
                        if error == nil {
                            self.fbLoginSuccess = true
                            
                            APIManager.shared.setLastLoggedInAs(user_type: self.userType) { (json) in
                                self.viewDidAppear(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func switchAccount(_ sender: Any) {
        let type = switchUser.selectedSegmentIndex
        
        if type == 0 {
            userType = USERTYPE_CUSTOMER
            userTypeImage.image = UIImage(named: "caveman")
        } else {
            userType = USERTYPE_EMPLOYEE
            userTypeImage.image = UIImage(named: "barber")
        }
    }
    
    
    
}





