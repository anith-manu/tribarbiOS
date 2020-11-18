//
//  EmployeeAccountViewController.swift
//  tribarb
//
//  Created by Anith Manu on 18/11/2020.
//

import UIKit

class EmployeeAccountViewController: UIViewController {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbShopName: UILabel!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var btLogout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btLogout.layer.cornerRadius = 5
        btLogout.layer.masksToBounds = true
        
        lbName.text = User.currentUser.name
        lbEmail.text = User.currentUser.email
        lbShopName.text = User.currentUser.shop
        
        if User.currentUser.pictureURL != nil {
            imgAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureURL!)!))
        }
        
        imgAvatar.layer.cornerRadius = 100/2
        imgAvatar.layer.borderWidth = 1.0
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tfPhone.text =  User.currentUser.phone
    }

    @IBAction func updateInfo(_ sender: Any) {
        
        var phone = ""
        
        if tfPhone.hasText {
            phone = tfPhone.text!
        } else {
            phone = User.currentUser.phone!
        }
        
        
        if phone != User.currentUser.phone! {
            APIManager.shared.employeeUpdateDetails(phone: phone) { (json) in
                User.currentUser.phone = phone
                self.viewWillAppear(true)
            }
        }
    }
    
    
    @IBAction func logout(_ sender: Any) {
        let alertView = UIAlertController(
            title: "Logging Out",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
            
            FBManager.shared.logOut()
            User.currentUser.resetEmployeeInfo()
            APIManager.shared.logout { (error) in
                if error != nil {
                    print("Error while logging out.")
                }
            }
            
            self.performSegue(withIdentifier: "EmployeeLogout", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel)
        
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
}
