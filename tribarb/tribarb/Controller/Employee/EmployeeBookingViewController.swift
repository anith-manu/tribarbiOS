//
//  EmployeeBookingViewController.swift
//  tribarb
//
//  Created by Anith Manu on 21/11/2020.
//

import UIKit
import SwiftyJSON
import CoreLocation
import MapKit

class EmployeeBookingViewController: UIViewController {


    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var lbBookingDate: UILabel!
    @IBOutlet weak var lbCustomer: UILabel!
    @IBOutlet weak var imgAvatar: CustomImageView!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var paymentModeImage: UIImageView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbSubtotal: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var lbRequest: UILabel!
    @IBOutlet weak var lbServiceFee: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var declineView: UIView!
    @IBOutlet weak var OTWView: UIView!
    @IBOutlet weak var CompleteView: UIView!
    @IBOutlet weak var tbvServices: ContentSizedTableView!
    
    var booking: Booking?
    var phone = ""
    var bookedServices = [JSON]()
    var destination: MKPlacemark?
    var source: MKPlacemark?
    var employeePin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    var locationManager: CLLocationManager!
    var client_address: String?
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIElements(booking: booking!)
        self.setDelegates()
    }
    
    
    func setDelegates() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            self.map.showsUserLocation = true
        }
        
        if booking?.status == "Barber En Route" {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateLocation(_:)), userInfo: nil, repeats: true)
        }
    }
    

    override func viewWillLayoutSubviews() {
        lbRequest.sizeToFit()
    }
    
    
    @objc func updateLocation(_ sender: AnyObject) {
        APIManager.shared.updateEmployeeLocation(location: self.lastLocation) { (json) in
            
        }
    }
    
    
    
    func getBooking() {

        APIManager.shared.getBooking(bookingID: (booking?.id)!) { (json) in

            let booking = Booking(json: json!["booking"])
            
            self.setUIElements(booking: booking)
            
        }
    }
    

    func setUIElements(booking: Booking) {
        navigationController?.view.backgroundColor = UIColor.white
        navigationItem.prompt = "Booking #\((booking.id)!)"
        
        var bookingType = ""
        if booking.booking_type == 0 {
            navigationItem.title = "Shop Booking"
            bookingType = "Shop Booking"
            self.mapView.isHidden = true
            self.OTWView.isHidden = true
        } else {
            navigationItem.title = "Home Booking"
            bookingType = "Home Booking"
            self.mapView.isHidden = false
            self.lbAddress.text = booking.home_address!
            self.client_address = booking.home_address!
            self.getLocation(booking.home_address!, "Client") { (dest) in
                self.destination = dest
            }
        }
        
        self.statusView.layer.cornerRadius = 10
        self.statusView.layer.masksToBounds = true
        if booking.status == "Placed" {
            self.startSkeletalAnimation(color: UIColor(red: 1.00, green: 0.76, blue: 0.36, alpha: 1.00))
        } else if booking.status == "Accepted" || booking.status == "Barber En Route"  {
            self.startSkeletalAnimation( color: UIColor(red: 0.23, green: 0.65, blue: 0.00, alpha: 1.00))
        } else if booking.status == "Cancelled" || booking.status == "Declined" {
            self.statusView.backgroundColor = .systemRed
        } else if  booking.status == "Completed" {
            self.statusView.backgroundColor = UIColor(red: 0.23, green: 0.65, blue: 0.00, alpha: 1.00)
            
            if booking.booking_type == 1 {
                self.timer.invalidate()
            }
        }
        self.lbStatus.text = booking.status!
        
        if booking.status == "Placed" {
            self.OTWView.isHidden = true
            self.CompleteView.isHidden = true
        }
        
        if booking.status == "Accepted" {
            self.acceptView.isHidden = true
            
            if booking.booking_type == 0 {
                self.OTWView.isHidden = true
                self.CompleteView.isHidden = false
            } else {
                self.OTWView.isHidden = false
                self.CompleteView.isHidden = true
            }
        }
        
        if booking.status == "Barber En Route" {
            self.declineView.isHidden = false
            self.CompleteView.isHidden = false
            self.acceptView.isHidden = true
            self.OTWView.isHidden = true
        }
        
        if booking.status == "Completed" || booking.status == "Cancelled" || booking.status == "Declined"  {
            self.mapView.isHidden = true
            self.buttonsView.isHidden = true
        }
        
        
        let dateString = booking.date!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "d MMM y, HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        self.lbBookingDate.text = bookingType + " on " + dateFormatter.string(from: date!)
        
        self.imgAvatar.layer.cornerRadius = imgAvatar.bounds.height/2
        self.imgAvatar.layer.borderWidth = 1.0
        self.imgAvatar.layer.borderColor = UIColor.white.cgColor
        self.imgAvatar.clipsToBounds = true
        
        if booking.customer_avatar != nil {
            imgAvatar.loadImage(booking.customer_avatar!)
        }
        
        self.lbCustomer.text = booking.customer!
        self.phone = booking.customer_phone!
        
        if let bookingDetails = booking.booking_details {
            self.bookedServices = bookingDetails
            self.tbvServices.reloadData()
        }
        
        self.lbSubtotal.text = "£\(booking.subtotal!)"
        self.lbServiceFee.text = "£\(booking.service_fee!)"
        self.lbTotal.text = "£\(booking.total!)"
        
        if booking.payment_mode == 0 {
            self.paymentModeImage.image = UIImage(named: "cash")
        } else {
            self.paymentModeImage.image = UIImage(named: "credit_card")
        }
        
        if booking.request! == "" {
            self.requestView.isHidden = true
        } else {
            self.requestView.isHidden = false
            self.lbRequest.text = booking.request!
        }
    }

    
    func startSkeletalAnimation(color: UIColor) {
        self.statusView.isSkeletonable = true
        self.statusView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: color), animation: nil, transition: .crossDissolve(0.7))
    }
    
    
    func stopSkeletalAnimation() {
        self.statusView.stopSkeletonAnimation()
        self.statusView.hideSkeleton()
    }
    

    
    @IBAction func call(_ sender: Any) {
        if let phoneCallURL = URL(string: "tel://\(phone)") {
            let application:UIApplication = UIApplication.shared
            
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
          }
    }
    
    
    @IBAction func openMaps(_ sender: Any) {
    
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(client_address!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                return
            }
            
            // Use your location
            let regionDistance: CLLocationDistance = 1000
            let coordinates = location.coordinate
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                
            let placemark = MKPlacemark(coordinate: coordinates)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Client"
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    
    @IBAction func acceptBooking(_ sender: Any) {
        let title = "Accept Booking"
        let message = "Are you sure you want to accept this booking?"
        performAction(alertTitle: title, alertMessage: message, bookingAction: 0)

    }
    
    
    @IBAction func declineBooking(_ sender: Any) {
        let title = "Decline Booking"
        let message = "Are you sure you want to decline this booking?"
        performAction(alertTitle: title, alertMessage: message, bookingAction: 1)
    }
    
    
    
    @IBAction func enrouteBooking(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateLocation(_:)), userInfo: nil, repeats: true)
        
        let title = "En Route"
        let message = "Are you on your way to the clients house?"
        performAction(alertTitle: title, alertMessage: message, bookingAction: 2)
    }
    
    
    @IBAction func completeBooking(_ sender: Any) {
        let title = "Complete Booking"
        let message = "Has this booking been completed?"
        performAction(alertTitle: title, alertMessage: message, bookingAction: 3)
    }
    
    func performAction(alertTitle: String, alertMessage: String, bookingAction: Int) {
        let alertView = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction!) in
            
            if bookingAction == 0 {
                APIManager.shared.employeeAcceptBooking(bookingID: (self.booking?.id)!) { (json) in
                    self.stopSkeletalAnimation()
                    self.getBooking()
                    
                }
                
            } else if bookingAction == 1 {
                APIManager.shared.employeeDeclineBooking(bookingID: (self.booking?.id)!) { (json) in
                    self.stopSkeletalAnimation()
                    self.getBooking()
                }
        
            } else if bookingAction == 2 {
                APIManager.shared.employeeEnroute(bookingID: (self.booking?.id)!) { (json) in
                    self.stopSkeletalAnimation()
                    self.getBooking()
                }
                
            } else if bookingAction == 3 {
                APIManager.shared.employeeCompleteBooking(bookingID: (self.booking?.id)!) { (json) in
                    self.stopSkeletalAnimation()
                    self.getBooking()
                }
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .default)
        
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
        
        
    }
    
    
}



extension EmployeeBookingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookedServices.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! BookingTableViewCell
        
        let item = bookedServices[indexPath.row]

        cell.lbServiceName.text = item["service"]["service_name"].string
        cell.lbServicePrice.text = "£\(String(item["service"]["price"].float!))"
        
        return cell
    }
}





extension EmployeeBookingViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        self.lastLocation = location.coordinate
        
//        // Creat pin annotation for employee
//        if employeePin != nil {
//            employeePin.coordinate = self.lastLocation
//        } else {
//            employeePin = MKPointAnnotation()
//            employeePin.title = "You"
//            employeePin.coordinate = self.lastLocation
//            self.map.addAnnotation(employeePin)
//        }
        
        // Reset zoom to cover the 3 locations
        var zoomRect = MKMapRect.null

        for annotation in self.map.annotations {
            let annotationPoint = MKMapPoint.init(annotation.coordinate)
            let pointRect = MKMapRect.init(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.union(pointRect)
        }
        
        let insetWidth = -zoomRect.size.width * 0.2
        let insetHeight = -zoomRect.size.height * 0.2
        let insetRect = zoomRect.insetBy(dx: insetWidth, dy: insetHeight)
        
        self.map.setVisibleMapRect(insetRect, animated: true)
    }
}



extension EmployeeBookingViewController: MKMapViewDelegate {
    
    // #1 - Delegate method of MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.lightGray
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    
    // #2 - Convert an address string to a location on the map
    func getLocation(_ address: String,_ title: String,_ completionHandler: @escaping (MKPlacemark) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                print("Error: ", error ?? "")
            }
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                // Create pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = title
                self.map.addAnnotation(dropPin)
                completionHandler(MKPlacemark.init(placemark: placemark))
            }
        }
    }
}
