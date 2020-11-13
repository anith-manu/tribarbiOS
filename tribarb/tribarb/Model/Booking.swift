//
//  Booking.swift
//  tribarb
//
//  Created by Anith Manu on 08/11/2020.
//

import Foundation
import SwiftyJSON


class Booking {
    
    var id: Int?
    var shopName: String?
    var booking_type: Int?
    var payment_mode: Int?
    var rating: Double?
    var date: String?
    var status: String?
    var home_address: String?
    var shop_address: String?
    var booking_details: [JSON]?
    var employee_name: String?
    var employee_phone: String?
    var shop_phone: String?
    var request: String?
    var total: Float?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.shopName = json["shop"]["name"].string
        self.booking_type = json["booking_type"].int
        self.payment_mode = json["payment_mode"].int
        self.rating = json["rating"].double
        self.date = json["requested_time"].string
        self.status = json["status"].string
        self.home_address = json["address"].string
        self.shop_address = json["shop"]["address"].string
        self.booking_details =  json["booking_details"].array
        self.employee_name = json["employee"]["name"].string
        self.employee_phone = json["employee"]["phone"].string
        self.shop_phone = json["shop"]["phone"].string
        self.request = json["requests"].string
        self.total = json["total"].float
    }
}

