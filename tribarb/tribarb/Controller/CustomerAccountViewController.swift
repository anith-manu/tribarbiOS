//
//  CustomerAccountViewController.swift
//  tribarb
//
//  Created by Anith Manu on 22/10/2020.
//

import UIKit
import FBSDKLoginKit


class CustomerAccountViewController: UIViewController {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbName.text = User.currentUser.name
        lbEmail.text = User.currentUser.email
        
        imgAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureURL!)!))
      

    }
    
    


    @IBAction func logOut(_ sender: Any) {
        FBManager.shared.logOut()
        User.currentUser.resetInfo()
        APIManager.shared.logout { (error) in
            if error != nil {
                print("Error while logging out.")
            }
        }
        
        performSegue(withIdentifier: "CustomerLogout", sender: self)
        
    }
    
}
