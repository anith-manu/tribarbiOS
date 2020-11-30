//
//  APIManager.swift
//  tribarb
//
//  Created by Anith Manu on 24/10/2020.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKLoginKit
import CoreLocation



class APIManager {
    
    
    static let shared = APIManager()
    
    let baseURL = NSURL(string: BASE_URL)
    
    var accessToken = ""
    var refreshToken = ""
    var expired = Date()
    
    

    func login(userType: String, completionHandler: @escaping (NSError?) -> Void) {

        let path = "api/social/convert-token/"
        let url = baseURL?.appendingPathComponent(path)
        let params: [String: Any] = [
            "grant_type": "convert_token",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "backend": "facebook",
            "token": AccessToken.current?.tokenString,
            "user_type": userType
        ]
        
        AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseString { (response) in
            
            switch response.result {
            case .success:
                
                let jsonData = try! JSON(data: response.data!)
                 
                self.accessToken = jsonData["access_token"].string!
                self.refreshToken = jsonData["refresh_token"].string!
                self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"].int!))
                completionHandler(nil)
    
                break
            
            case .failure(let error):
                completionHandler(error as NSError?)
                break
            }
        }
        
    }
    
    

    
    

    func logout(completionHandler: @escaping (NSError?) -> Void) {

        let path = "api/social/revoke-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "token": self.accessToken
        ]
        
        
        AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseString { (response) in
            
            switch response.result {
            case .success:
                completionHandler(nil)
                break
            
            case .failure(let error):
                completionHandler(error as NSError?)
                        
            }
        }
    }
    

    
    
 
    func requestServer(_ method: Alamofire.HTTPMethod,_ path: String,_ params: [String: Any]?,_ encoding: ParameterEncoding,_ completionHandler: @escaping (JSON?) -> Void) {
        
        
        let url = baseURL?.appendingPathComponent(path)
        
        AF.request(url!, method: method, parameters: params, encoding: encoding, headers: nil).responseJSON{ response in
            
            switch response.result {
            case .success:
                let jsonData = try! JSON(data: response.data!)
                completionHandler(jsonData)
                break
                
            case .failure:
                completionHandler(nil)
                break
            }
        }
    }
    
    
    
    
    /** CUSTOMER **/
    
    func get_shops(filterID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/shops/\(filterID)/"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    
   
    func getServices(filterID: Int, shopID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/services/\(filterID)/\(shopID)"
        requestServer(.get, path, nil,  JSONEncoding.default, completionHandler)
    }
    
    

    func getServiceAlbum(serviceID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/service/album/\(serviceID)"
        requestServer(.get, path, nil,  JSONEncoding.default, completionHandler)
    }
    
    

    func createBooking(completionHandler: @escaping (JSON?) -> Void) {
        
        let path = "api/customer/booking/add/"
        let simpleArray = Cart.currentCart.items
        let jsonArray = simpleArray.map { item in
            return [
                "service_id": item.service.id!
            ]
        }
        
        let shopID = Cart.currentCart.shop?.id
        
        if JSONSerialization.isValidJSONObject(jsonArray) {
            do  {
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                
                let params: [String: Any] = [
                    "access_token": self.accessToken,
                    "shop_id": shopID!,
                    "booking_details": dataString,
                    "booking_type": "\(Cart.currentCart.bookingType!)",
                    "requested_time": "\(Cart.currentCart.bookingTime!)",
                    "requests": "\(Cart.currentCart.request!)",
                    "payment_mode": "\(Cart.currentCart.paymentMode!)",
                    "address": Cart.currentCart.address,
                    "total": Cart.currentCart.getTotal()
                ]
                
                requestServer(.post, path, params, URLEncoding(), completionHandler)
            }
            catch {
                
                print("JSON serialization failed: \(error)")
                
            }
        }
    }
    
    
    
    func getStripeSecret(completionHandler: @escaping (JSON?) -> Void) {
        
        let path = "api/customer/stripe/secret/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "total": Cart.currentCart.getTotal()
        ]
        requestServer(.get, path, params, URLEncoding(), completionHandler)
    }
    
    

//    func getLatestBooking(completionHandler: @escaping (JSON?) -> Void) {
//
//        let path = "api/customer/booking/latest/"
//        let params: [String: Any] = [
//            "access_token": self.accessToken
//        ]
//        requestServer(.get, path, params, URLEncoding(), completionHandler)
//    }
//
//
//

    
    func customerGetBookings(filterID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/bookings/\(filterID)/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
    
        requestServer(.get, path, params,  URLEncoding(), completionHandler)
    }
    
    
   
    func getBooking(bookingID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/booking/get/\(bookingID)/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
    
        requestServer(.get, path, params,  URLEncoding(), completionHandler)
    }
    
    
   
    func cancelBooking(bookingID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/booking/cancel/\(bookingID)/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
 
    func customerGetDetails(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/getinfo/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
    
        requestServer(.get, path, params,  URLEncoding(), completionHandler)
    }
    
    
    
    func customerUpdateDetails(phone: String, address: String, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/updateinfo/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "phone": phone,
            "address": address
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    
    func customerUpdateRating(bookingID: Int, rating: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/shop/updaterating/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "booking_id" : bookingID,
            "rating": rating
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    func getEmployeeLocation(completionHandler: @escaping (JSON?) -> Void){
        let path = "api/customer/employee/location/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
        requestServer(.get, path, params, URLEncoding(), completionHandler)
    }
    
    
    func employeeVerification(shopID: Int, token: String, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/employee/verify/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "shop_id" : shopID,
            "token": token
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    
    func getLastLoggedInAs(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/check/last-logged-in-as/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
    
        requestServer(.get, path, params,  URLEncoding(), completionHandler)
    }
    
    
    
    func setLastLoggedInAs(user_type: String, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/set/last-logged-in-as/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "user_type" : user_type
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    
    func employeeGetDetails(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/employee/getinfo/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
    
        requestServer(.get, path, params,  URLEncoding(), completionHandler)
    }
    
    
    
    func employeeUpdateDetails(phone: String, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/employee/updateinfo/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "phone": phone
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    func employeeGetBookings(filterID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/employee/bookings/\(filterID)/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
    
        requestServer(.get, path, params,  URLEncoding(), completionHandler)
    }
    
    
    func employeeAcceptBooking(bookingID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/employee/booking/accept/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "booking_id": bookingID
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    func employeeDeclineBooking(bookingID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/employee/booking/decline/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "booking_id": bookingID
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    func employeeEnroute(bookingID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/employee/booking/enroute/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "booking_id": bookingID
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    
    func employeeCompleteBooking(bookingID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/employee/booking/complete/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "booking_id": bookingID
        ]
    
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
    
    func updateEmployeeLocation(location: CLLocationCoordinate2D, completionHandler: @escaping (JSON?) -> Void){
        
        let path = "api/employee/location/update/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "location": "\(location.latitude),\(location.longitude)"
        ]
        
        requestServer(.post, path, params,  URLEncoding(), completionHandler)
    }
    
    
}
