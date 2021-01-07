//
//  EmployeeBookingTableViewCell.swift
//  tribarb
//
//  Created by Anith Manu on 20/11/2020.
//

import UIKit

class EmployeeBookingTableViewCell: UITableViewCell {

    @IBOutlet weak var lbBookingType: UILabel!
    @IBOutlet weak var lbBookingDate: UILabel!
    @IBOutlet weak var lbCustomer: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbBarberName: UILabel!
    @IBOutlet weak var barberView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
