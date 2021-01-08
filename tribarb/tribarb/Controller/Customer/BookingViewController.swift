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
import SkeletonView

class BookingViewController: UIViewController{
    
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

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var homeAddressView: UIView!
    @IBOutlet weak var shopAddressView: UIView!
    @IBOutlet weak var lbHomeAddress: UILabel!
    @IBOutlet weak var lbShopAddress: UILabel!
    @IBOutlet weak var lbBookingType: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbBarberName: UILabel!
    @IBOutlet weak var lbSubTotal: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var paymentModeImage: UIImageView!
    @IBOutlet weak var lbRequest: UILabel!
    @IBOutlet weak var lbThanksForRating: UILabel!
    @IBOutlet weak var lbServiceFee: UILabel!
    @IBOutlet weak var btSubmitRating: UIButton!
    @IBOutlet weak var bookingScrollView: UIScrollView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var barberView: UIView!
    @IBOutlet weak var tbvServices: UITableView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var starsView: UIView!
    @IBOutlet weak var btCancel: CurvedButton!
    
    var booking: Booking?
    var bookedServices = [JSON]()
    var phone = ""
    var fromController: Int = 0
    var destination: MKPlacemark?
    var source: MKPlacemark?
    var employeePin: MKPointAnnotation!
    var timer = Timer()
    var shop_address: String?
    var shop_name: String?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setRatingsView()
        setBookingViewUIElements(booking: booking!)
        if booking!.status == "Barber En Route" {
            self.setTimer()
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        lbRequest.sizeToFit()
    }
    
    
    func setRatingsView() {
        ratingView.isHidden = true
        starsView.addSubview(cosmosView)
        cosmosView.centerInSuperview()
        btSubmitRating.layer.cornerRadius = 10
        btSubmitRating.layer.masksToBounds = true
    }

    
    func getBooking() {
        APIManager.shared.getBooking(bookingID: (booking?.id)!) { (json) in
            
            let booking = Booking(json: json!["booking"])
            
            self.setBookingViewUIElements(booking: booking)
        
        }
    }
    
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getEmployeeLocation(_:)), userInfo: nil, repeats: true)
    }
    
    
    @objc func getEmployeeLocation(_ sender: AnyObject) {
        APIManager.shared.getEmployeeLocation { (json) in
            
            if let location = json?["location"].string {
                
                let split = location.components(separatedBy: ",")
                let lat = split[0]
                let lng = split[1]
                
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat)!, longitude: CLLocationDegrees(lng)!)
            
                
                // Creat pin annotation for employee
                if self.employeePin != nil {
                    self.employeePin.coordinate = coordinate
                } else {
                    self.employeePin = MKPointAnnotation()
                    self.employeePin.coordinate = coordinate
                    self.employeePin.title = "Barber"
                    self.map.addAnnotation(self.employeePin)
                }
                
                // Reset zoom to cover the 3 locations
                self.autoZoom()
            } else {
                self.timer.invalidate()
            }
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
            if let bookingID = self.booking?.id {
                self.startCancelSkeletalAnimation()
                APIManager.shared.cancelBooking(bookingID: bookingID) { (json) in
                
                    if json!["status"] == "success" {
                        self.getBooking()
                    } else {
                        self.bookingCancelledFailedMessage()
                    }
                }
                self.stopCancelSkeletalAnimation()
            }
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .default)
        
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)        
    }
    
    
    func startCancelSkeletalAnimation() {
        self.btCancel.isSkeletonable = true
        self.btCancel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: UIColor(rgb: 0xFFC15D), secondaryColor: UIColor(rgb: 0xffdeaa)), animation: nil, transition: .crossDissolve(0.25))
    }
    
    
    func stopCancelSkeletalAnimation() {
        self.btCancel.stopSkeletonAnimation()
        self.btCancel.hideSkeleton()
    }
    
    
    func setBookingViewUIElements(booking: Booking) {
        navigationController?.view.backgroundColor = UIColor.white
        navigationItem.prompt = "Booking #\(booking.id!)"
        navigationItem.title = booking.shopName!
        
        self.shop_name = booking.shopName!
        
        self.statusView.layer.cornerRadius = 10
        self.statusView.layer.masksToBounds = true
        
        if booking.status == "Placed" {
            self.startSkeletalAnimation(color: UIColor(red: 1.00, green: 0.76, blue: 0.36, alpha: 1.00))
        } else if booking.status == "Accepted" || booking.status == "Barber En Route"  {
            self.startSkeletalAnimation( color: UIColor(red: 0.23, green: 0.65, blue: 0.00, alpha: 1.00))
        } else if booking.status == "Cancelled" || booking.status == "Declined" {
            self.stopSkeletalAnimation()
            self.statusView.backgroundColor = .systemRed
        } else if  booking.status == "Completed" {
            self.stopSkeletalAnimation()
            self.statusView.backgroundColor = UIColor(red: 0.23, green: 0.65, blue: 0.00, alpha: 1.00)
        }
        
        
        var bookingType = ""
        if booking.booking_type == 0 {
            bookingType = "Shop booking"
            self.homeAddressView.isHidden = true
            self.shopAddressView.isHidden = false
            self.lbShopAddress.text = booking.shop_address!
            self.shop_address = booking.shop_address!
            
        } else {
            bookingType = "Home booking"
            self.homeAddressView.isHidden = false
            self.shopAddressView.isHidden = true
            self.lbHomeAddress.text = booking.home_address!
            
            self.getLocation(booking.home_address!, "Home") { (dest) in
                self.destination = dest
                self.setMapFocus(centerCoordinate: dest.coordinate, radiusInKm: 1)
            }
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
            self.paymentModeImage.image = UIImage(named: "cash")
        } else {
            self.paymentModeImage.image = UIImage(named: "credit_card")
        }
        
        
        self.lbStatus.text = booking.status!
        if booking.status != "Placed" {
            self.cancelView.isHidden = true
        }
        
        
        if booking.status == "Completed" || booking.status == "Cancelled" || booking.status == "Declined"  {
           
            self.shopAddressView.isHidden = true
            if booking.status == "Completed" {
                self.ratingView.isHidden = false
                self.cosmosView.rating = booking.rating!
                
                if self.cosmosView.rating > 0 {
                    self.lbThanksForRating.text = "Rating Submitted"
                    self.btSubmitRating.isHidden = true
                    self.cosmosView.settings.updateOnTouch = false
                }
            }
        }
                
        self.lbSubTotal.text = "£\(booking.subtotal!)"
        self.lbServiceFee.text = "£\(booking.service_fee!)"
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
    
    
    @IBAction func openMaps(_ sender: Any) {
    
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(shop_address!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                return
            }
            
            let regionDistance: CLLocationDistance = 1000
            let coordinates = location.coordinate
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                
            let placemark = MKPlacemark(coordinate: coordinates)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.shop_name
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    
    @IBAction func submitRating(_ sender: Any) {
        self.lbThanksForRating.text = "Rating Submitted"
        self.btSubmitRating.isHidden = true
        
        let rating = Int(self.cosmosView.rating)
        
        if let bookingID = booking?.id{
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
    
    
    func startSkeletalAnimation(color: UIColor) {
        self.statusView.isSkeletonable = true
        self.statusView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: color), animation: nil, transition: .crossDissolve(0.7))
    }
    
    
    func stopSkeletalAnimation() {
        self.statusView.stopSkeletonAnimation()
        self.statusView.hideSkeleton()
    }
    
    
    func setMapFocus(centerCoordinate: CLLocationCoordinate2D, radiusInKm radius: CLLocationDistance) {
        let diameter = radius * 2000
        let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: diameter, longitudinalMeters: diameter)
        self.map.setRegion(region, animated: false)
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



