//
//  Booking.swift
//  tribarb
//
//  Created by Anith Manu on 08/11/2020.
//

import Foundation
import SwiftyJSON

class Bookings {
    
    var id: Int?
    var shopName: String?
    var booking_type: String?
    var date: String?
    var status: String?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.shopName = json["shop"]["name"].string
        self.booking_type = "\(json["booking_type"])"
        self.date = json["requested_time"].string
        self.status = json["status"].string
    }
}

