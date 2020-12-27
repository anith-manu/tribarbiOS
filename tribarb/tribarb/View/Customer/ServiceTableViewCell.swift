//
//  ServiceTableViewCell.swift
//  tribarb
//
//  Created by Anith Manu on 28/10/2020.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var lbServiceName: UILabel!
    @IBOutlet weak var lbServiceShortDescription: UILabel!
    @IBOutlet weak var lbServicePrice: UILabel!
    @IBOutlet weak var lbBooked: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
