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

class CustomerAccountViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextViewDelegate {

    @IBOutlet weak var accountScroll: UIScrollView!
    @IBOutlet weak var accountStackView: UIStackView!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var tbPhone: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var btUpdate: CurvedButton!
    
    var locationManager: CLLocationManager!
    var previousLocation: CLLocation?
    
    private let imageView = CustomImageView()
    
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 20
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupDelegates()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        disableUpdateButton()
        
        if User.currentUser.name == nil {
            APIManager.shared.customerGetDetails { (json) in
                if json != nil {
                    User.currentUser.setCustomerInfo(json: json!)
                    self.setCustomerInfo()
                }
            }
        } else {
            setCustomerInfo()
        }
        
        
        if addressTextView.text == "" {
            addressTextView.text = "Enter address here"
            addressTextView.textColor = UIColor.lightGray
        } else {
            addressTextView.textColor = UIColor.black
        }
    }
    
    
    func disableUpdateButton() {
        self.btUpdate.isEnabled = false
        self.btUpdate.layer.opacity = 0.5
    }
    
    
    func enableUpdateButton() {
        self.btUpdate.isEnabled = true
        self.btUpdate.layer.opacity = 1
    }
    
    
    private func setupDelegates() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneClicked))
        doneButton.tintColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        toolbar.setItems([doneButton], animated: false)
        
        addressTextView.layer.borderWidth = 0
        addressTextView.delegate = self
        accountScroll.delegate = self
        accountScroll.keyboardDismissMode = .interactive
        addressTextView.inputAccessoryView = toolbar
        tbPhone.inputAccessoryView = toolbar
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tbPhone.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        enableUpdateButton()
    }
    
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }
    
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)

        imageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if addressTextView.textColor == UIColor.lightGray {
            addressTextView.text = nil
            addressTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if addressTextView.text.isEmpty {
            addressTextView.text = "Enter address here"
            addressTextView.textColor = UIColor.lightGray
        }
    }
    

    func setCustomerInfo() {
        map.removeAnnotations(map.annotations)
        navigationItem.title = User.currentUser.name

        if User.currentUser.pictureURL != nil {
            imageView.loadImage(User.currentUser.pictureURL!)
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
        enableUpdateButton()
    }
    
    
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
 
    
    @IBAction func searchAddress(_ sender: Any) {
        var address = addressTextView.text!
        
        if addressTextView.textColor == UIColor.lightGray {
            address = ""
        }
        
        if address != "" && address != User.currentUser.address! {
            print("Called")
            map.removeAnnotations(map.annotations)
            pinAddress(address: address)
        }
        
        if address != User.currentUser.address! {
            enableUpdateButton()
        }
    }
    
    
    func pinAddress(address: String) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                let alertController = UIAlertController(title: "Could Not Find Address", message: "Please enter a valid address.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Cancel", style: .default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                self.disableUpdateButton()
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
            
            beamsClient.clearAllState {
                print("Notifications off.")
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

        
        var address = addressTextView.text!
        
        if addressTextView.textColor == UIColor.lightGray {
            address = ""
        }
        
        if address != User.currentUser.address! {
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                if (error != nil) && address != "" {
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
        
        disableUpdateButton()
    }
    
 
    
    func updateCompleteMessage() {
        let message = "Updated Successfully"
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

