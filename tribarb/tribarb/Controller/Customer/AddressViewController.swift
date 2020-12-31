//
//  AddressViewController.swift
//  tribarb
//
//  Created by Anith Manu on 20/10/2020.
//

import UIKit
import MapKit
import CoreLocation

class AddressViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var addressStackView: UIStackView!
    @IBOutlet weak var addressScrollView: UIScrollView!
    @IBOutlet weak var savedAddress: UIView!
    @IBOutlet weak var lbSavedAddress: UILabel!
    @IBOutlet weak var newAddress: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var btDifferentAddress: UIButton!
    
    @IBOutlet weak var addressTextView: UITextView!
    
    var locationManager: CLLocationManager!
    var ADDRESS_SET = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneClicked))
        doneButton.tintColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        
        toolbar.setItems([doneButton], animated: false)
        
        addressTextView.inputAccessoryView = toolbar
        
        addressTextView.layer.cornerRadius = 5
        addressTextView.layer.borderColor = UIColor.lightGray.cgColor
        addressTextView.layer.borderWidth = 0.30
        addressTextView.layer.masksToBounds = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            self.map.showsUserLocation = true
        }
        
        if User.currentUser.address != nil && User.currentUser.address! != "" {
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
    
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        

    }
    
    
    @objc func touchMap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        map.removeAnnotations(map.annotations)
        
        let geoCoder = CLGeocoder()
        
        let location = gestureRecognizer.location(in: map)
        let coordinate = map.convert(location, toCoordinateFrom: map)
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    
        
        geoCoder.reverseGeocodeLocation(clLocation) { (placemarks, error) in
            
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the user
                return
            }
        
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let postalCode = placemark.postalCode ?? ""
            let city = placemark.locality ?? ""
            let country = placemark.country ?? ""
 
            DispatchQueue.main.async {
                self.addressTextView.text = "\(streetNumber) \(streetName), \(postalCode), \(city), \(country)"
            }
        }
       
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
   
    @objc func keyboardAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
          
            if tabBarController?.tabBar.bounds.height != nil {
                self.addressScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.addressStackView.frame.height+keyboardHeight-(tabBarController?.tabBar.bounds.height)!)
                
            }
        }
         
    }
    
    
    @objc func keyboardDisappear(_ notification: Notification) {
        self.addressScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.addressStackView.frame.height)
    }
    
    
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @IBAction func addPayment(_ sender: Any) {
        
         if ADDRESS_SET == false {
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
        
        map.removeAnnotations(map.annotations)
        
        var address = ""
        
        address = addressTextView.text!
        
        if address == "" {
            address = User.currentUser.address!
        }
        
        self.pinAddress(address: address)
    }
    
    
    func pinAddress(address: String) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                let alertController = UIAlertController(title: "Could Not Find Address", message: "Please enter a valid address.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Cancel", style: .default)
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
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchMap(_:)))
        gestureRecognizer.delegate = self
        map.addGestureRecognizer(gestureRecognizer)
        
        self.btDifferentAddress.isHidden = true
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



