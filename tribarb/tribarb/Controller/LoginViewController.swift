//
//  LoginViewController.swift
//  tribarb
//
//  Created by Anith Manu on 22/10/2020.
//

import UIKit
import FBSDKLoginKit


class LoginViewController: UIViewController {
    
    static var USER_TYPE = 0
    var fbLoginSuccess = false
    var userType: String = USERTYPE_CUSTOMER
    @IBOutlet weak var switchUser: UISegmentedControl!
    @IBOutlet weak var userTypeImage: UIImageView!
    @IBOutlet weak var facebookLogin: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.switchUser.isHidden = true
        self.facebookLogin.isHidden = true
        self.activityIndicator.isHidden = true
        
        
        if (AccessToken.current != nil ) {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            FBManager.getFBUserData {
                APIManager.shared.login(userType: self.userType) { (error) in
                    if error == nil {
                        self.fbLoginSuccess = true
                        self.viewDidAppear(true)
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            self.switchUser.isHidden = false
            self.facebookLogin.isHidden = false
        }

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (AccessToken.current != nil && fbLoginSuccess == true) {
            APIManager.shared.getLastLoggedInAs { (json) in
                if json != nil {
                    if json!["last_logged_in_as"] ==  "customer" {
                        LoginViewController.USER_TYPE = 0
                        self.performSegue(withIdentifier: "CustomerView", sender: self)
                    } else if json!["last_logged_in_as"] ==  "employee" {
                        LoginViewController.USER_TYPE = 1
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
                    self.activityIndicator.isHidden=false
                    self.activityIndicator.startAnimating()
                    APIManager.shared.login(userType: self.userType) { (error) in
                        if error == nil {
                        
                            self.fbLoginSuccess = true
                            
                            
                            APIManager.shared.setLastLoggedInAs(user_type: self.userType) { (json) in
                                self.viewDidAppear(true)
                                self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            } else {
                let alertView = UIAlertController(
                    title: "Error",
                    message: error.debugDescription,
                    preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            
                alertView.addAction(cancelAction)
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func switchAccount(_ sender: Any) {
        let type = switchUser.selectedSegmentIndex
        
        if type == 0 {
            userType = USERTYPE_CUSTOMER
            userTypeImage.image = UIImage(named: "logo")
        } else {
            userType = USERTYPE_EMPLOYEE
            userTypeImage.image = UIImage(named: "barber")
        }
    }
    
    
    
}





