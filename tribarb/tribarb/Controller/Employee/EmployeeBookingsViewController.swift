//
//  EmployeeBookingsViewController.swift
//  tribarb
//
//  Created by Anith Manu on 18/11/2020.
//

import UIKit

class EmployeeBookingsViewController: UIViewController {

    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        super.viewDidLoad()
        tabbarConfig()
        // Do any additional setup after loading the view.
    }
    
    func tabbarConfig() {
        guard let tabbar = self.tabBarController?.tabBar else { return }
        tabbar.layer.cornerRadius = 30
        tabbar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabbar.layer.masksToBounds = true
        tabbar.barTintColor = .black
        tabbar.tintColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
