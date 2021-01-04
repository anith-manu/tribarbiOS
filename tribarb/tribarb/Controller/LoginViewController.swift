//
//  LoginViewController.swift
//  tribarb
//
//  Created by Anith Manu on 22/10/2020.
//

import UIKit
import FBSDKLoginKit
import SkeletonView

class LoginViewController: UIViewController {
    
    static var USER_TYPE = 0
    var fbLoginSuccess = false
    var userType: String = USERTYPE_CUSTOMER
    @IBOutlet weak var switchUser: UISegmentedControl!
    @IBOutlet weak var userTypeImage: UIImageView!
    @IBOutlet weak var facebookLogin: UIButton!
    
    @IBOutlet weak var background: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientBackground()
       
        
        self.switchUser.isHidden = true
        self.facebookLogin.isHidden = true
        
        if (AccessToken.current != nil ) {
            
            startSkeletalAnimation()
            FBManager.getFBUserData {
                APIManager.shared.login(userType: self.userType) { (error) in
                    if error == nil {
                        self.fbLoginSuccess = true
                        self.viewDidAppear(true)
                        self.stopSkeletalAnimation()
                    }
                }
            }
        } else {
            self.switchUser.isHidden = false
            self.facebookLogin.isHidden = false
        }
    }
    
    
    func startSkeletalAnimation() {
        self.background.isSkeletonable = true
        self.background.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: UIColor(rgb: 0xFFC15D), secondaryColor: UIColor(rgb: 0xffdeaa)), animation: nil, transition: .crossDissolve(0.25))
    }
    
    
    func stopSkeletalAnimation() {
        self.background.stopSkeletonAnimation()
        self.view.hideSkeleton()
    }
    
    
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor(rgb: 0xFFC15D).cgColor, UIColor(rgb: 0xFFC15D).cgColor, UIColor(rgb: 0xffcb77).cgColor, UIColor(rgb: 0xffd590).cgColor, UIColor(rgb: 0xffdeaa).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.background.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (AccessToken.current != nil && fbLoginSuccess == true) {
            APIManager.shared.getLastLoggedInAs { (json) in
                if json != nil {
                    if json!["last_logged_in_as"] ==  "customer" {
                        LoginViewController.USER_TYPE = 0
                        self.performSegue(withIdentifier: "CustomerView", sender: self)
                    } else if json!["last_logged_in_as"] ==  "employee" {
                        self.switchUser.isHidden = false
                        self.facebookLogin.isHidden = false
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
                    self.startSkeletalAnimation()
                    APIManager.shared.login(userType: self.userType) { (error) in
                        if error == nil {
                        
                            self.fbLoginSuccess = true
                            
                            
                            APIManager.shared.setLastLoggedInAs(user_type: self.userType) { (json) in
                                self.viewDidAppear(true)
                                self.stopSkeletalAnimation()
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
            userTypeImage.image = UIImage(named: "tribarb-logo")
        } else {
            userType = USERTYPE_EMPLOYEE
            userTypeImage.image = UIImage(named: "barber")
        }
    }
    
    
    
}






