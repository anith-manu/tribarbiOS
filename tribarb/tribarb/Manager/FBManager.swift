//
//  FBManager.swift
//  tribarb
//
//  Created by Anith Manu on 22/10/2020.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON
import PushNotifications


class FBManager {
    
    static let shared = LoginManager()
    
    
    public class func getFBUserData(completionHandler: @escaping () -> Void) {
        
        if (AccessToken.current != nil) {

            GraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture.type(normal)"]).start { (connection, result, error) in
    
                if (error ==  nil) {
                    
                    completionHandler()
                    
                    // Set customer info
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        if LoginViewController.USER_TYPE == 0 {
                            APIManager.shared.customerGetDetails { (json) in
                                if json != nil {
                                    User.currentUser.setCustomerInfo(json: json!)
                                    self.setUserIDBeams(email: User.currentUser.email ?? "")
                                }
                            }
                        } else {
                            APIManager.shared.employeeGetDetails { (json) in
                                if json != nil {
                                    User.currentUser.setEmployeeInfo(json: json!)
                                    self.setUserIDBeams(email: User.currentUser.email ?? "")
                                }
                            }
                        }
                    }
                } else {
                    print(error ?? "")
                }
            }
        }
    }
    
    
    static func setUserIDBeams(email: String) {
        // basic authentication credentials
        print("calledddd")
            // Token Provider
            let tokenProvider = BeamsTokenProvider(authURL: "http://tribarb.herokuapp.com/api/beamstoken/") { () -> AuthData in
                let headers = ["": ""]
                let queryParams: [String: String] = ["access_token": globalAccessToken]
                return AuthData(headers: headers, queryParams: queryParams)
            }

            // Get the Beams token and send it to Pusher
            beamsClient.setUserId(
                email,
                tokenProvider: tokenProvider,
                completion: { error in
                    guard error == nil else {
                        print(error.debugDescription)
                        return
                    }
                    print("Successfully authenticated with Beams")
                }
            )
    }
}
