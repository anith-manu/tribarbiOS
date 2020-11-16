//
//  User.swift
//  TribarbMobile
//
//  Created by Anith Manu on 25/06/2020.
//  Copyright © 2020 tribarb. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    
    var name: String?
    var phone: String?
    var address: String?
    var email: String?
    var pictureURL: String?
    
    static let currentUser = User()
    
    func setCustomerInfo(json: JSON) {

        self.name = json["customer"]["name"].string
        self.email = json["customer"]["email"].string
        self.phone = json["customer"]["phone"].string
        self.address = json["customer"]["address"].string
        self.pictureURL = json["customer"]["avatar"].string
    
    }
    
    func resetCustomerInfo() {
        self.name = nil
        self.email = nil
        self.phone = nil
        self.address = nil
        self.pictureURL = nil
    }
}
