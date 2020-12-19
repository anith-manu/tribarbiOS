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
        var subtotal: Float = 0
        
        for item in self.items {
            subtotal = subtotal + item.service.price!
        }
        return subtotal
    }
    
    func getServiceFee() -> Float {
        return (shop?.service_fee)!
    }
    
    func getTotal() -> Float {
        let subTotal = getSubtotal()
        let total = subTotal + (shop?.service_fee)!
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
