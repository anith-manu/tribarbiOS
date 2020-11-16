//
//  PreviousBookingsTableViewController.swift
//  tribarb
//
//  Created by Anith Manu on 21/10/2020.
//

import UIKit

class PreviousBookingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
