//
//  CustomerAccountViewController.swift
//  tribarb
//
//  Created by Anith Manu on 22/10/2020.
//

import UIKit
import FBSDKLoginKit
import CoreLocation


class CustomerAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbPhoneNumber: UILabel!
    
    @IBOutlet weak var tbPhone: UITextField!
    @IBOutlet weak var tbLine1: UITextField!
    @IBOutlet weak var tbLine2: UITextField!
    @IBOutlet weak var tbCity: UITextField!
    @IBOutlet weak var tbPostCode: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbName.text = User.currentUser.name
        lbEmail.text = User.currentUser.email
        
        imgAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureURL!)!))
      
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        APIManager.shared.customerGetDetails { (json) in
            
            if json != nil {
                User.currentUser.phone = json!["customer"]["phone"].string
                User.currentUser.address = json!["customer"]["address"].string
                
                if User.currentUser.address! == "" || User.currentUser.address == nil {
                    self.lbAddress.text = "No address set."
                } else {
                    self.lbAddress.text = User.currentUser.address!
                    
                }
                self.lbPhoneNumber.text =  User.currentUser.phone!
                
            }
            
    
        }
    }
    
    

    @IBAction func logOut(_ sender: Any) {
        let alertView = UIAlertController(
            title: "Logging Out",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
            
            FBManager.shared.logOut()
            User.currentUser.resetInfo()
            APIManager.shared.logout { (error) in
                if error != nil {
                    print("Error while logging out.")
                }
            }
            
            self.performSegue(withIdentifier: "CustomerLogout", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel)
        
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    @IBAction func updateInfo(_ sender: Any) {
        
        
        var phone = ""
        
        if tbPhone.hasText {
            phone = tbPhone.text!
        } else {
            phone = User.currentUser.phone!
        }

        var address = ""
        
        if tbLine1.hasText {
            address = address + tbLine1.text! + ", "
        }
        
        if tbLine2.hasText {
            address = address + tbLine2.text! + ", "
        }
        
        if tbCity.hasText {
            address = address + tbCity.text! + ", "
        }
        
        if tbPostCode.hasText {
            address = address + tbPostCode.text!
        }
        
        if address == "" {
            address = User.currentUser.address!
        }
        
        if address != User.currentUser.address! {
            
            if tbCity.text == "" || tbPostCode.text == "" {
                // Showing alert that the field is required
                let alertController = UIAlertController(title: "Incomplete Address", message: "Town/City and Postcode/Country fields are required.", preferredStyle: .alert)
        
                let okAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString(address) { (placemarks, error) in
                    if (error != nil) {
                        let alertController = UIAlertController(title: "Invalid Address", message: "Please enter a valid address.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Cancel", style: .cancel)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        
                        APIManager.shared.customerUpdateDetails(phone: phone, address: address) { (json) in
                            print(json)
                            self.viewWillAppear(true)
                        }
                        
                    }
                }
            }
        }
        
        if phone != User.currentUser.phone! {
            APIManager.shared.customerUpdateDetails(phone: phone, address: address) { (json) in
                print(json)
                self.viewWillAppear(true)
            }
        }
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
