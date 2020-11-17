//
//  FBManager.swift
//  tribarb
//
//  Created by Anith Manu on 22/10/2020.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON


class FBManager {
    
    static let shared = LoginManager()
    
    
    public class func getFBUserData(completionHandler: @escaping () -> Void) {
        
        if (AccessToken.current != nil) {
            GraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture.type(normal)"]).start { (connection, result, error) in
                
                if (error ==  nil) {
            
                    completionHandler()
                    
                    // Set customer info
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        APIManager.shared.customerGetDetails { (json) in
                            if json != nil {
                                User.currentUser.setCustomerInfo(json: json!)
                            }
                        }
                    }
                }
            }
        }
    }
}
