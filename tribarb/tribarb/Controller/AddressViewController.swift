//
//  AddressViewController.swift
//  tribarb
//
//  Created by Anith Manu on 20/10/2020.
//

import UIKit
import MapKit
import CoreLocation

class AddressViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var savedAddress: UIView!
    @IBOutlet weak var lbSavedAddress: UILabel!
    @IBOutlet weak var newAddress: UIView!
    @IBOutlet weak var tbLine1: UITextField!
    @IBOutlet weak var tbLine2: UITextField!
    @IBOutlet weak var tbCity: UITextField!
    @IBOutlet weak var tbPostcode: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var btDifferentAddress: UIButton!
    
    var locationManager: CLLocationManager!
    var ADDRESS_SET = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            self.map.showsUserLocation = true
        }
        
        if User.currentUser.address != nil && User.currentUser.address! != "" {
            print("called")
            self.btDifferentAddress.isHidden = false
            self.newAddress.isHidden = true
            self.lbSavedAddress.text = User.currentUser.address!
            self.pinAddress(address: User.currentUser.address!)
            Cart.currentCart.address = User.currentUser.address!
        } else {
            ADDRESS_SET = false
            self.lbSavedAddress.text = "No address set."
            self.newAddress.isHidden = false
            self.btDifferentAddress.isHidden = true
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @IBAction func addPayment(_ sender: Any) {
        
         if ADDRESS_SET == false {
            let alertController = UIAlertController(title: "Address Not Set", message: "Please enter a valid address.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            print(Cart.currentCart.address)
           // Cart.currentCart.address = tbAddress.text
            self.performSegue(withIdentifier: "PaymentHomeBooking", sender: self)
        }
    }
    

    
    @IBAction func searchAddress(_ sender: Any) {
        
        if tbCity.text == "" || tbPostcode.text == "" {
            // Showing alert that the field is required
            let alertController = UIAlertController(title: "Incomplete Address", message: "Town/City and Postcode fields are required.", preferredStyle: .alert)
    
            let okAction = UIAlertAction(title: "OK", style: .default)
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            map.removeAnnotations(map.annotations)
            
            var address = ""
            
            if tbLine1.hasText {
                address = address + tbLine1.text! + ", "
            }
            
            if tbLine2.hasText {
                address = address + tbLine2.text! + ", "
            }
            
            if tbCity.hasText {
                address = address + tbCity.text! + ", "
            }
            
            if tbPostcode.hasText {
                address = address + tbPostcode.text!
            }
            
            if address == "" {
                address = User.currentUser.address!
            }
            
            self.pinAddress(address: address)
        }
    }
    
    
    func pinAddress(address: String) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                let alertController = UIAlertController(title: "Could Not Find Address", message: "Please enter a valid address.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.map.setRegion(region, animated: true)
                self.locationManager.stopUpdatingLocation()
                
                // Create pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                self.map.addAnnotation(dropPin)
                self.ADDRESS_SET = true
                
                self.lbSavedAddress.text = address
                Cart.currentCart.address = address
            }
        }
        
    }
    
    

    @IBAction func chooseDifferentAddress(_ sender: Any) {
        self.newAddress.isHidden = false
        self.viewWillAppear(true)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
  
    
 
}



extension AddressViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
    }
}



