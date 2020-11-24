//
//  BookingViewController.swift
//  tribarb
//
//  Created by Anith Manu on 09/11/2020.
//

import UIKit
import SwiftyJSON
import Cosmos
import TinyConstraints
import MapKit

class BookingViewController: UIViewController {
    
    lazy var cosmosView: CosmosView = {
        var view = CosmosView()
        view.settings.totalStars = 5
        view.settings.starSize = 40
        view.settings.fillMode = .full
        view.settings.filledColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        view.settings.filledBorderColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        view.settings.emptyBorderColor = .lightGray
        view.settings.filledBorderWidth = 1.5
        view.settings.emptyBorderWidth = 1.5
        view.rating = 0
        return view
    }()

    @IBOutlet weak var lbShopName: UILabel!
    @IBOutlet weak var lbBookingType: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbAddressType: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbBarberName: UILabel!
    @IBOutlet weak var lbSubTotal: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var lbPaymentMethod: UILabel!
    @IBOutlet weak var lbRequest: UILabel!
    @IBOutlet weak var lbThanksForRating: UILabel!
    @IBOutlet weak var btSubmitRating: UIButton!
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var barberView: UIView!
    @IBOutlet weak var tbvServices: UITableView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var starsView: UIView!
    
    var bookedServices = [JSON]()
    var phone = ""
    
    var bookingId: Int?
    
    var fromController: Int = 0
    
    let activityIndicator = UIActivityIndicatorView()
    
    var destination: MKPlacemark?
    var source: MKPlacemark?
    var driverPin: MKPointAnnotation!
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingView.isHidden = true
        // Do any additional setup after loading the view.
        starsView.addSubview(cosmosView)
        cosmosView.centerInSuperview()
        btSubmitRating.layer.cornerRadius = 10
        btSubmitRating.layer.masksToBounds = true
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        getBooking()
    }
    
    

    
    func getBooking() {
        Helpers.showBookingActivityIndicator(activityIndicator, view)
    

        APIManager.shared.getBooking(bookingID: bookingId!) { (json) in
            
            
            let booking = Booking(json: json!["booking"])
            
            self.setUIElements(booking: booking)
            
            Helpers.hideActivityIndicator(self.activityIndicator)
        }
    }
    
    
    
    func bookingCancelledMessage() {
        let message = "Booking has been cancelled."
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)

        // duration in seconds
        let duration: Double = 2

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
    
    func bookingCancelledFailedMessage() {
        let alertView = UIAlertController(
            title: "Unable To Cancel",
            message: "This booking has already been accepted. If you would like to cancel, please call the barber.",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelBooking(_ sender: Any) {
        
        let alertView = UIAlertController(
            title: "Cancel Booking?",
            message: "Are you sure you want to cancel this booking?",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction!) in
            if let bookingID = self.bookingId {
                APIManager.shared.cancelBooking(bookingID: bookingID) { (json) in
            
                    if json!["status"] == "success" {
                        self.viewWillAppear(true)
                    } else {
                        self.bookingCancelledFailedMessage()
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .default)
        
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)        
    }
    
    
    
    
    func setUIElements(booking: Booking) {
        self.title = "Booking #\(booking.id!)"
        self.lbShopName.text = booking.shopName!
        
        var bookingType = ""
        if booking.booking_type == 0 {
            bookingType = "Shop booking"
            self.lbAddressType.text = "Shop Address : "
            self.lbAddress.text = booking.shop_address!
        } else {
            bookingType = "Home booking"
            self.lbAddressType.text = "Home Address : "
            self.lbAddress.text = booking.home_address!
        }
        
        let dateString = booking.date!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "d MMM y, HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        
        self.lbBookingType.text = bookingType + " on " + dateFormatter.string(from: date!)
        

        if booking.employee_name == nil {
            self.barberView.isHidden = true
        } else {
            self.barberView.isHidden = false
            self.lbBarberName.text = booking.employee_name!
            
            if booking.employee_phone! != "" {
                self.phone = booking.employee_phone!
            } else {
                self.phone = booking.shop_phone!
            }
        }
        
        if let bookingDetails = booking.booking_details {
            self.bookedServices = bookingDetails
            self.tbvServices.reloadData()
        }
        
        if booking.request! == "" {
            self.requestView.isHidden = true
        } else {
            self.requestView.isHidden = false
            self.lbRequest.text = booking.request!
        }

        if booking.payment_mode == 0 {
            self.lbPaymentMethod.text = "Cash"
        } else {
            self.lbPaymentMethod.text = "Card"
        }
        
        
        self.lbStatus.text = booking.status!
        if booking.status != "Placed" {
            self.cancelView.isHidden = true
        }
        
        if booking.status == "Completed" || booking.status == "Cancelled" || booking.status == "Declined"  {
            self.mapView.isHidden = true
            
            if booking.status == "Completed" {
                self.ratingView.isHidden = false
                self.cosmosView.rating = booking.rating!
                
                if self.cosmosView.rating > 0 {
                    self.lbThanksForRating.text = "Rating Submitted"
                    self.btSubmitRating.isHidden = true
                    self.cosmosView.settings.updateOnTouch = false
                }
            }
        } else {
            self.mapView.isHidden = false
//            self.getLocation(booking.home_address!, "You") { (dest) in
//                self.destination = dest
//                
//                self.getLocation(booking.shop_address!, "Shop") { (sou) in
//                    self.source = sou
//                    self.getDirections()
//                }
//            }
            
        }
        
        // SERVICE FEE MODIFY HERE
        self.lbSubTotal.text = "£\(booking.total! - 1.5)"
        self.lbTotal.text = "£\(booking.total!)"
        
        
    }

    
    
    @IBAction func callBarber(_ sender: Any) {
        if let phoneCallURL = URL(string: "tel://\(phone)") {
            let application:UIApplication = UIApplication.shared
            
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
          }
    }
    
    
    
    @IBAction func submitRating(_ sender: Any) {
        self.lbThanksForRating.text = "Rating Submitted"
        self.btSubmitRating.isHidden = true
        
    
        let rating = Int(self.cosmosView.rating)
        

        if let bookingID = self.bookingId {
            APIManager.shared.customerUpdateRating(bookingID: bookingID, rating: rating) { (json) in
            }
        }
    }
    
    func autoZoom() {
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


extension BookingViewController: UITableViewDelegate, UITableViewDataSource {
    
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


extension BookingViewController: MKMapViewDelegate {
    
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
                print("Error: ", error)
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
    
    
    // #3 - Get direction and zoom to address
    func getDirections() {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.init(placemark: source!)
        request.destination = MKMapItem.init(placemark: destination!)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            
            if error != nil {
                print("Error:", error)
            } else {
                // Show route
                self.showRoute(response: response!)
                self.autoZoom()
            }
        }
    }
    
    // #4 - Show route between locations and make zoom
    func showRoute(response: MKDirections.Response) {
        
        for route in response.routes {
            self.map.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        
        
    }
    
}



final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

