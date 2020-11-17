//
//  EmployeeVerificationViewController.swift
//  tribarb
//
//  Created by Anith Manu on 16/11/2020.
//

import UIKit

class EmployeeVerificationViewController: UIViewController {
    @IBOutlet weak var tbShopId: UITextField!
    @IBOutlet weak var tbToken: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func submit(_ sender: Any) {
        let shop_id = Int(tbShopId.text!)
        let token = tbToken.text!
        
        APIManager.shared.employeeVerification(shopID: shop_id!, token: token) { (json) in
            
            let status = json!["status"]
            
            if status == "success"{
                //Perform segue
                self.performSegue(withIdentifier: "EmployeeView", sender: self)
            } else {
                let alertController = UIAlertController(title: "Incorrect Credentials", message: "Please enter valid credentials.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        
    }
    
}
