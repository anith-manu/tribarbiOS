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

    @IBOutlet weak var lbBookingType: UILabel!
    @IBOutlet weak var lbBookingDate: UILabel!
    @IBOutlet weak var lbCustomer: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbStatus: UILabel!
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbSubtotal: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var lbPaymentMode: UILabel!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var lbRequest: UILabel!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var declineView: UIView!
    @IBOutlet weak var OTWView: UIView!
    @IBOutlet weak var CompleteView: UIView!
    @IBOutlet weak var tbvServices: ContentSizedTableView!
    
    var bookingId: Int?
    var bookingStatus: String?
    
    var phone = ""
    var bookedServices = [JSON]()
    let activityIndicator = UIActivityIndicatorView()
    
    var destination: MKPlacemark?
    var source: MKPlacemark?
    var employeePin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    
    var locationManager: CLLocationManager!
    var client_address: String?
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.addressView.isHidden = true
        self.mapView.isHidden = true
        
        self.imgAvatar.layer.cornerRadius = 75/2
        self.imgAvatar.layer.borderWidth = 1.0
        self.imgAvatar.layer.borderColor = UIColor.white.cgColor
        self.imgAvatar.clipsToBounds = true
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            self.map.showsUserLocation = true
        }
        
       
        if bookingStatus! == "Barber En Route" {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateLocation(_:)), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBooking()
    }
    
    override func viewWillLayoutSubviews() {
        lbRequest.sizeToFit()
    }
    
    @objc func updateLocation(_ sender: AnyObject) {
        APIManager.shared.updateEmployeeLocation(location: self.lastLocation) { (json) in
            
        }
    }
    
    
    
    func getBooking() {
        Helpers.showWhiteOutActivityIndicator(activityIndicator, view)

        APIManager.shared.getBooking(bookingID: bookingId!) { (json) in

            let booking = Booking(json: json!["booking"])
            
            self.setUIElements(booking: booking)
            
            Helpers.hideActivityIndicator(self.activityIndicator)
        }
    }

    func setUIElements(booking: Booking) {
        self.title = "Booking #\(bookingId!)"
        
        if booking.booking_type == 0 {
            self.lbBookingType.text = "Shop Booking"
            self.OTWView.isHidden = true
        } else {
            self.lbBookingType.text = "Home booking"
            self.mapView.isHidden = false
            self.addressView.isHidden = false
            self.lbAddress.text = booking.home_address!
            self.client_address = booking.home_address!
            
            self.getLocation(booking.home_address!, "Client") { (dest) in
                self.destination = dest

            }
        }
        

        if booking.status == "Completed" || booking.status == "Cancelled" || booking.status == "Declined"  {
            self.mapView.isHidden = true
            self.buttonsView.isHidden = true
            
            if booking.status == "Completed" && booking.booking_type == 1 {
                self.timer.invalidate()
            }

        }
        
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
        
        
        if booking.request! == "" {
            self.requestView.isHidden = true
        } else {
            self.requestView.isHidden = false
            self.lbRequest.text = booking.request!
        }
        
        let dateString = booking.date!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "d MMM y, HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        self.lbBookingDate.text = dateFormatter.string(from: date!)
        
        if booking.customer_avatar != nil {
            self.imgAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: booking.customer_avatar!)!))
        }
        
        self.lbCustomer.text = booking.customer!
        self.phone = booking.customer_phone!
        
        self.lbStatus.text = booking.status!
        
        if let bookingDetails = booking.booking_details {
            self.bookedServices = bookingDetails
            self.tbvServices.reloadData()
        }
        
        
        if booking.payment_mode == 0 {
            self.lbPaymentMode.text = "Cash"
        } else {
            self.lbPaymentMode.text = "Card"
        }
        
        
        // SERVICE FEE MODIFY HERE
        self.lbSubtotal.text = "£\(booking.total! - 1.5)"
        self.lbTotal.text = "£\(booking.total!)"

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
                APIManager.shared.employeeAcceptBooking(bookingID: self.bookingId!) { (json) in
                    self.viewWillAppear(true)
                }
                
            } else if bookingAction == 1 {
                APIManager.shared.employeeDeclineBooking(bookingID: self.bookingId!) { (json) in
                    self.viewWillAppear(true)
                }
        
            } else if bookingAction == 2 {
                APIManager.shared.employeeEnroute(bookingID: self.bookingId!) { (json) in
                    self.viewWillAppear(true)
                }
                
            } else if bookingAction == 3 {
                APIManager.shared.employeeCompleteBooking(bookingID: self.bookingId!) { (json) in
                    self.viewWillAppear(true)
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



class CurvedButton : UIButton {

   override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
   }

   required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
   }

   private func setup() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true    
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
