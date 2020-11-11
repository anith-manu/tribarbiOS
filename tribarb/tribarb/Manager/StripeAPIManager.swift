import Foundation
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

import Stripe

class MyAPIClient: NSObject, STPCustomerEphemeralKeyProvider {

    let baseURL = NSURL(string: BASE_URL)


    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {

        let path = "api/customer/stripe/"
        let url = baseURL?.appendingPathComponent(path)

        let access = APIManager.shared.accessToken

        let params: [String: Any] = ["access_token": access, "api_version":apiVersion]
    
        AF.request(url!, method: .get, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { response in

            let data = response.data
            guard let json = ((try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]) as [String : Any]??) else {
                completion(nil, response.error)
                return
            }
            completion(json, nil)
        }
    }
    
    
}

