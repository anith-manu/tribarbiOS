//
//  EmployeeVerificationViewController.swift
//  tribarb
//
//  Created by Anith Manu on 16/11/2020.
//

import UIKit

class EmployeeVerificationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var tbShopId: UITextField!
    @IBOutlet weak var tbToken: UITextField!
    @IBOutlet var background: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func submit(_ sender: Any) {
        let shop_id = Int(tbShopId.text!)
        let token = tbToken.text!
        
        APIManager.shared.employeeVerification(shopID: shop_id!, token: token) { (json) in
            
            guard let status = json?["status"] else {
                self.invalidCredentialsMessage()
                return
            }
            
            if status == "success"{
                //Perform segue
                self.performSegue(withIdentifier: "EmployeeView", sender: self)
            } else {
                self.invalidCredentialsMessage()
            }
            
        }
        
    }
    
    func invalidCredentialsMessage() {
        let alertController = UIAlertController(title: "Incorrect Credentials", message: "Please enter valid credentials.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor(rgb: 0xFFC15D).cgColor, UIColor(rgb: 0xFFC15D).cgColor, UIColor(rgb: 0xffcb77).cgColor, UIColor(rgb: 0xffd590).cgColor, UIColor(rgb: 0xffdeaa).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.background.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
