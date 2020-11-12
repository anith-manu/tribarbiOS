//
//  Shops.swift
//  tribarb
//
//  Created by Anith Manu on 26/10/2020.
//

import Foundation
import SwiftyJSON

class Shop {
    
    var id: Int?
    var name: String?
    var phone: String?
    var address: String?
    var logo: String?
    var instagram: String?
    var facebook: String?
    var totalRating: Float?
    var numberOfRatings: Float?
    
    
    init(json: JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.phone = json["phone"].string
        self.address = json["address"].string
        self.logo = json["logo"].string
        self.instagram = json["instagram"].string
        self.facebook = json["facebook"].string
        self.totalRating = json["totalRating"].float
        self.numberOfRatings = json["numberOfRatings"].float
    }
}
