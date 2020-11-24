//
//  PaymentViewController.swift
//  tribarb
//
//  Created by Anith Manu on 03/11/2020.
//

import UIKit
import Stripe

class PaymentViewController: UIViewController {

    @IBOutlet weak var paymentMethod: UISegmentedControl!

    var customerContext : STPCustomerContext?
    var paymentContext : STPPaymentContext?
   
    let currentShop = Cart.currentCart.shop?.name
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customerContext = STPCustomerContext(keyProvider: MyAPIClient())
        paymentContext = STPPaymentContext(customerContext: customerContext!)
        self.paymentContext?.delegate = self
        self.paymentContext?.hostViewController = self
        self.paymentContext?.paymentAmount = 5000
        STPTheme.default().accentColor = .black
        STPTheme.default().primaryBackgroundColor = .white
        STPTheme.default().primaryForegroundColor = .black
        STPTheme.default().secondaryBackgroundColor = .white
        STPTheme.default().secondaryForegroundColor = .blue
        STPTheme.default().errorColor = .red

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
  

    @IBAction func placeBooking(_ sender: Any) {
        Cart.currentCart.paymentMode = paymentMethod.selectedSegmentIndex
        
        if paymentMethod.selectedSegmentIndex == 1 {
            self.paymentContext?.requestPayment()
        } else {
            APIManager.shared.createBooking { (json) in
                Cart.currentCart.reset()
                self.tabBarController?.tabBar.items?[1].isEnabled = false
                self.tabBarController?.tabBar.items?[1].badgeValue = nil
               // self.performSegue(withIdentifier: "BookingStatus", sender: self)
                self.performSegue(withIdentifier: "BackToCart", sender: self)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BackToCart" {
            let vc = segue.destination as? CheckoutViewController
            vc?.fromController = 1
            vc?.shopName = currentShop
        }
    }
    

    @IBAction func changePayment(_ sender: Any) {
        if paymentMethod.selectedSegmentIndex == 1 {
            self.paymentContext?.presentPaymentOptionsViewController()
        }
    }
}



extension PaymentViewController: STPPaymentContextDelegate {
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
        APIManager.shared.getStripeSecret { (json) in
          
            let clientSecret = json!["clientSecret"].string
            
            let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret!)
            paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
            
            STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { (status, paymentIntent, error) in
               
                switch status {
                case .succeeded:
                    APIManager.shared.createBooking { (json) in
                        Cart.currentCart.reset()
                        self.tabBarController?.tabBar.items?[1].isEnabled = false
                        self.tabBarController?.tabBar.items?[1].badgeValue = nil
                        //self.performSegue(withIdentifier: "BookingStatus", sender: self)
                        self.performSegue(withIdentifier: "BackToCart", sender: self)
                    }
                    // Your backend asynchronously fulfills the customer's order, e.g. via webhook
                    completion(.success, nil)
                case .failed:
                
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
                    let alertView = UIAlertController(
                        title: error.unsafelyUnwrapped.localizedDescription,
                        message: "Please try a different card or pay with cash.",
                        preferredStyle: .alert)
                    alertView.addAction(cancelAction)
                    self.present(alertView, animated: true, completion: nil)
                    completion(.error, error) // Report error
                case .canceled:
                    completion(.userCancellation, nil) // Customer cancelled
                @unknown default:
                    completion(.error, nil)
                }
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    

}
