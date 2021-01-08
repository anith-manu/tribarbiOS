//
//  Helpers.swift
//  tribarb
//
//  Created by Anith Manu on 26/10/2020.
//

import Foundation
import SwiftyJSON
import PushNotifications



class Helpers {
    
    
    static func setUserIDBeams(email: String) {
        // basic authentication credentials
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
