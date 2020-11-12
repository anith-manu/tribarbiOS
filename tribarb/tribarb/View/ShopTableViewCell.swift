//
//  ShopTableViewCell.swift
//  tribarb
//
//  Created by Anith Manu on 26/10/2020.
//

import UIKit

class ShopTableViewCell: UITableViewCell {

    @IBOutlet weak var lbShopName: UILabel!
    @IBOutlet weak var lbShopAddress: UILabel!
    @IBOutlet weak var shopLogo: UIImageView!
    @IBOutlet weak var shadowLayer: ShadowView!
    @IBOutlet weak var mainBackground: UIView!
    @IBOutlet weak var lbRating: UILabel!
    @IBOutlet weak var lbNewlyAdded: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var lbNumberOfRatings: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }




}
