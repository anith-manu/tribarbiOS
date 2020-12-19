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
    var from: String?
    var to: String?
    var customer: String?
    var customer_phone: String?
    var customer_avatar: String?
    var service_fee: Float?
    var subtotal: Float?
    
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
        self.from = json["shop"]["address"].string
        self.to = json["address"].string
        self.customer = json["customer"]["name"].string
        self.customer_phone = json["customer"]["phone"].string
        self.customer_avatar = json["customer"]["avatar"].string
        self.service_fee = json["service_fee"].float
        self.subtotal = json["subtotal"].float
        self.total = json["total"].float
    }
}

