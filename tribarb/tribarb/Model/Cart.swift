//
//  Cart.swift
//  tribarb
//
//  Created by Anith Manu on 01/11/2020.
//

import Foundation

class CartItem {
    
    var service: Service
    
    init(service: Service) {
        self.service = service
    }
}


class Cart {
    
    static let currentCart = Cart()
    
    var shop: Shop?
    var items = [CartItem]()
    var address: String?
    var request: String?
    var bookingType: Int?
    
    
    func getTotal() -> Float {
        var total: Float = 0
        
        for item in self.items {
            total = total + item.service.price!
        }
        return total
    }
    
    func reset() {
        self.shop = nil
        self.items = []
        self.address = nil
        self.request = nil
        self.bookingType = nil
    }
    
}
