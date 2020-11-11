//
//  FilterBookingTableViewCell.swift
//  tribarb
//
//  Created by Anith Manu on 08/11/2020.
//

import UIKit

class FilterBookingTableViewCell: UITableViewCell {

    @IBOutlet weak var lbShopName: UILabel!
    @IBOutlet weak var lbBookingType: UILabel!
    @IBOutlet weak var lbBookingDate: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
