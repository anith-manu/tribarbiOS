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


class APIManager {
    
    static let shared = APIManager()
    
    let baseURL = NSURL(string: BASE_URL)
    
    var accessToken = ""
    var refreshToken = ""
    var expired = Date()
    
    
    // API to login user
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
    
    
    // API to logout user
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
    
    
    
    // Request server function
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
    
    // API for getting Barbershop list that offers shop bookings
    func get_shop_booking_shops(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/shops/shop-booking/"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    
    // API for getting Barbershop list that offers home bookings
    func get_home_booking_shops(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/shops/home-booking/"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    
    // API for getting shop service list
    func getShopServices(shopID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/shop-services/\(shopID)"
        requestServer(.get, path, nil,  JSONEncoding.default, completionHandler)
    }
    
    
    // API for getting home service list
    func getHomeServices(shopID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/home-services/\(shopID)"
        requestServer(.get, path, nil,  JSONEncoding.default, completionHandler)
    }
    
    
    // API for getting home service list
    func getServiceAlbum(serviceID: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/service/album/\(serviceID)"
        requestServer(.get, path, nil,  JSONEncoding.default, completionHandler)
    }
    
    
    
    
}
