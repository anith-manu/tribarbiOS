//
//  CheckoutTableViewCell.swift
//  tribarb
//
//  Created by Anith Manu on 01/11/2020.
//

import UIKit

class CheckoutTableViewCell: UITableViewCell {

    @IBOutlet weak var lbServiceName: UILabel!
    @IBOutlet weak var lbServicePrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
