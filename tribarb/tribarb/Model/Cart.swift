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
    var address = ""
    var request: String?
    var bookingType: Int?
    var paymentMode: Int?
    var bookingTime: String?
    
    
    
    func getSubtotal() -> Float {
        var total: Float = 0
        
        for item in self.items {
            total = total + item.service.price!
        }
        return total
    }
    
    func getTotal() -> Float {
        let subTotal = getSubtotal()
        let total = subTotal + 1.50
        return total
    }
    
    func reset() {
        self.shop = nil
        self.items = []
        self.address = ""
        self.request = nil
        self.bookingType = nil
        self.paymentMode = nil
        self.bookingTime = nil
    }
    
}
