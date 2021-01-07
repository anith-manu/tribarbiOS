//
//  PaymentViewController.swift
//  tribarb
//
//  Created by Anith Manu on 03/11/2020.
//

import UIKit
import Stripe
import CoreLocation
import MapKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var paymentMethod: UISegmentedControl!
    @IBOutlet weak var btPlaceBooking: CurvedButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbBookingTime: UILabel!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var lbSubTotal: UILabel!
    @IBOutlet weak var lbServiceFee: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    var customerContext : STPCustomerContext?
    var paymentContext : STPPaymentContext?
   
    let currentShop = Cart.currentCart.shop?.name
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPaymentUI()
        setupStripe()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BackToCart" {
            let vc = segue.destination as? CheckoutViewController
            vc?.fromController = 1
            vc?.shopName = currentShop
        }
    }
  
    
    func setPaymentUI() {
        navigationController?.navigationBar.prefersLargeTitles = true

        var bookingType = ""
        if Cart.currentCart.bookingType == 0 {
            bookingType = "Shop booking"
            self.mapView.isHidden = true
        } else {
            bookingType = "Home booking"
            self.mapView.isHidden = false
            self.lbAddress.text = "\(Cart.currentCart.address)"
            setHomePin()
        }
        
        let dateString = Cart.currentCart.bookingTime!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "d MMM y, HH:mm"
       
        self.lbBookingTime.text = bookingType + " on " + dateFormatter.string(from: date!)
        self.lbServiceFee.text = "£\(Cart.currentCart.getServiceFee())"
        self.lbSubTotal.text = "£\(Cart.currentCart.getSubtotal())"
        self.lbTotal.text = "£\(Cart.currentCart.getTotal())"
    }
    
    
    func setupStripe() {
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
    
    
    func setHomePin() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(Cart.currentCart.address) { (placemarks, error) in
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.map.setRegion(region, animated: true)
                
                // Create pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                self.map.addAnnotation(dropPin)
            }
        }
    }
    

    @IBAction func placeBooking(_ sender: Any) {
        
        
        disablePlacedBookingButton()
        Cart.currentCart.paymentMode = paymentMethod.selectedSegmentIndex
        
        if paymentMethod.selectedSegmentIndex == 1 {
            self.paymentContext?.requestPayment()
        } else {
            APIManager.shared.createBooking { (json) in
                Cart.currentCart.reset()
                self.tabBarController?.tabBar.items?[1].isEnabled = false
                self.tabBarController?.tabBar.items?[1].badgeValue = nil
                self.performSegue(withIdentifier: "BackToCart", sender: self)
            }
        }
    }
    
    

    @IBAction func changePayment(_ sender: Any) {
        if paymentMethod.selectedSegmentIndex == 1 {
            self.paymentContext?.presentPaymentOptionsViewController()
        }
    }
    
    func disablePlacedBookingButton() {
        btPlaceBooking.isEnabled = false
        paymentMethod.isEnabled = false
        btPlaceBooking.isSkeletonable = true
        self.btPlaceBooking.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: UIColor(rgb: 0xFFC15D), secondaryColor: UIColor(rgb: 0xffdeaa)), animation: nil, transition: .crossDissolve(0.25))
    }
    
    func enablePlacedBookingButton() {
        btPlaceBooking.isEnabled = true
        paymentMethod.isEnabled = true
        self.btPlaceBooking.stopSkeletonAnimation()
        self.btPlaceBooking.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
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
                    self.enablePlacedBookingButton()
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


