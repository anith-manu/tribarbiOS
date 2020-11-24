//
//  Booking.swift
//  tribarb
//
//  Created by Anith Manu on 08/11/2020.
//

import Foundation
import SwiftyJSON

class EmployeeBookings{
    
    var id: Int?
    var booking_type: String?
    var date: String?
    var status: String?
    var address: String?
    var customer: String?
    var barber: String?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.booking_type = "\(json["booking_type"])"
        self.date = json["requested_time"].string
        self.status = json["status"].string
        self.address = json["address"].string
        self.customer = json["customer"]["name"].string
        self.barber = json["employee"]["name"].string
    }
}

