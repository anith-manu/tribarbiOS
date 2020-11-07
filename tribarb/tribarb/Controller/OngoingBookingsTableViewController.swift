//
//  OngoingBookingsTableViewController.swift
//  tribarb
//
//  Created by Anith Manu on 21/10/2020.
//

import UIKit

class OngoingBookingsTableViewController: UITableViewController {
    
    var fromController: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if fromController == 1 {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath)
        
        return cell
    }


}
