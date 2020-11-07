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

    @IBOutlet weak var tbBuilding: CustomTextField!
    @IBOutlet weak var tbHouseNo: CustomTextField!
    @IBOutlet weak var tbCity: CustomTextField!
    @IBOutlet weak var tbPostCode: CustomTextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var addPayment: UIButton!
    var locationManager: CLLocationManager!
    var VALID_ADDRESS = false
    
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func addPayment(_ sender: Any) {
        
        if tbCity.text == "" || tbPostCode.text == "" {
            // Showing alert that the field is required
            let alertController = UIAlertController(title: "Incomplete Address", message: "Town/City and Postcode fields are required.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else if VALID_ADDRESS == false {
            let alertController = UIAlertController(title: "Address Not Set", message: "Please enter a valid address.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
           // Cart.currentCart.address = tbAddress.text
            self.performSegue(withIdentifier: "PaymentHomeBooking", sender: self)
        }
        
    }
    
    
    @IBAction func searchAddress(_ sender: Any) {
        if tbCity.text == "" || tbPostCode.text == "" {
            VALID_ADDRESS = false
            // Showing alert that the field is required
            let alertController = UIAlertController(title: "Incomplete Address", message: "Town/City and Postcode fields are required.", preferredStyle: .alert)
    
            let okAction = UIAlertAction(title: "OK", style: .default)
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            map.removeAnnotations(map.annotations)
            
            let addressOptional = tbBuilding.text! + ", " + tbHouseNo.text!
            let addressEssential = tbCity.text! + ", " + tbPostCode.text!
            let address = addressOptional + ", " + addressEssential
            Cart.currentCart.address = address
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                
                if (error != nil) {
                    self.VALID_ADDRESS = false
                    let alertController = UIAlertController(title: "Could Not Find Address", message: "Please enter a valid address.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
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
                    self.VALID_ADDRESS = true
                }
            }
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("called")
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



