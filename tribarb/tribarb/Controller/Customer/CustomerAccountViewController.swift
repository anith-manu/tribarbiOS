//
//  CustomerAccountViewController.swift
//  tribarb
//
//  Created by Anith Manu on 22/10/2020.
//

import UIKit
import FBSDKLoginKit
import MapKit
import CoreLocation

class CustomerAccountViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var accountScroll: UIScrollView!
    @IBOutlet weak var accountStackView: UIStackView!
    
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var tbPhone: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var previousLocation: CLLocation?
    let activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchMap(_:)))
        gestureRecognizer.delegate = self
        map.addGestureRecognizer(gestureRecognizer)
        
        if CLLocationManager.locationServicesEnabled() { 
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            self.map.showsUserLocation = true
        }
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        accountScroll.keyboardDismissMode = .interactive
        
        
        imgAvatar.layer.cornerRadius = 100/2
        imgAvatar.layer.borderWidth = 1.0
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.clipsToBounds = true
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneClicked))
        doneButton.tintColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        toolbar.setItems([doneButton], animated: false)
        
        addressTextView.inputAccessoryView = toolbar
        tbPhone.inputAccessoryView = toolbar
        
        addressTextView.layer.cornerRadius = 5
        addressTextView.layer.borderColor = UIColor.lightGray.cgColor
        addressTextView.layer.borderWidth = 0.30
        addressTextView.layer.masksToBounds = true
    
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        if User.currentUser.name == nil {
            accountScroll.isHidden = true
            Helpers.showWhiteOutActivityIndicator(activityIndicator, view)
            APIManager.shared.customerGetDetails { (json) in
                if json != nil {
                    User.currentUser.setCustomerInfo(json: json!)
                    self.setCustomerInfo()
                }
                Helpers.hideActivityIndicator(self.activityIndicator)
                self.accountScroll.isHidden = false
            }
        } else {
            setCustomerInfo()
        }
        
    }
    
    
    func setCustomerInfo() {
        map.removeAnnotations(map.annotations)
        lbName.text = User.currentUser.name
        lbEmail.text = User.currentUser.email
        
        if User.currentUser.pictureURL != nil {
            imgAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureURL!)!))
        }
        
        addressTextView.text = User.currentUser.address
        tbPhone.text =  User.currentUser.phone
        
        if User.currentUser.address ?? "" != "" {
            pinAddress(address: User.currentUser.address!)
        }
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
    
    
    
    
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
 
    
    @IBAction func searchAddress(_ sender: Any) {
        map.removeAnnotations(map.annotations)
        
        var address = ""
        
        address = addressTextView.text!
        
        if address == "" {
            address = User.currentUser.address!
        }
        pinAddress(address: address)
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

                Cart.currentCart.address = address
            }
        }
        
    }
    
    
    

    @objc func keyboardAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            
            if tabBarController?.tabBar.bounds.height != nil {
                accountScroll.contentSize = CGSize(width: self.view.frame.width, height: accountStackView.frame.height+keyboardHeight-(tabBarController?.tabBar.bounds.height)!)
            }
        }
         
    }
    
    
    @objc func keyboardDisappear(_ notification: Notification) {
        accountScroll.contentSize = CGSize(width: self.view.frame.width, height: accountStackView.frame.height)
    }
    
    


    @IBAction func logOut(_ sender: Any) {
        let alertView = UIAlertController(
            title: "Logging Out",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction!) in
            
            FBManager.shared.logOut()
            User.currentUser.resetCustomerInfo()
            APIManager.shared.logout { (error) in
                if error != nil {
                    print("Error while logging out.")
                }
            }
            
            self.performSegue(withIdentifier: "CustomerLogout", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .default)
        
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    @IBAction func updateInfo(_ sender: Any) {
        
        
        var phone = ""
        
        if tbPhone.hasText {
            phone = tbPhone.text!
        } else {
            phone = User.currentUser.phone!
        }

        
        var address = ""
        
        if addressTextView.hasText {
            address = addressTextView.text!
        }
        
        if address == "" {
            address = User.currentUser.address!
        }
        
        if address != User.currentUser.address! {
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                if (error != nil) {
                    let alertController = UIAlertController(title: "Invalid Address", message: "Please enter a valid address.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Cancel", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    
                    APIManager.shared.customerUpdateDetails(phone: phone, address: address) { (json) in
                        User.currentUser.address = address
                        self.viewWillAppear(true)
                        self.updateCompleteMessage()
                    }
                    
                    
                }
            }
            
        }
        
        if phone != User.currentUser.phone! {
            APIManager.shared.customerUpdateDetails(phone: phone, address: address) { (json) in
                User.currentUser.phone = phone
                self.viewWillAppear(true)
                self.updateCompleteMessage()
            }
        }
        
    }
    
    
    
    func updateCompleteMessage() {
        let message = "Successfully Updated"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        self.present(alert, animated: true)

        // duration in seconds
        let duration: Double = 1

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
}




extension CustomerAccountViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
    }
}

