//
//  Service.swift
//  tribarb
//
//  Created by Anith Manu on 28/10/2020.
//

import Foundation
import SwiftyJSON

class Service {
    
    var id: Int?
    var name: String?
    var short_description: String?
    var price: Float?
    
    init(json: JSON) {
        
        self.id = json["id"].int
        self.name = json["service_name"].string
        self.short_description = json["short_description"].string
        self.price = json["price"].float
    }
}

