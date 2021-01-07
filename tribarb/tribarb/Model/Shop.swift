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
    var service_fee: Float?
    
    
    init(json: JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.phone = json["phone"].string
        self.address = json["address"].string
        self.logo = json["logo"].string
        self.instagram = json["instagram"].string
        self.facebook = json["facebook"].string
        self.totalRating = json["total_rating"].float
        self.numberOfRatings = json["number_of_ratings"].float
        self.service_fee = json["service_fee"].float
    }
}
