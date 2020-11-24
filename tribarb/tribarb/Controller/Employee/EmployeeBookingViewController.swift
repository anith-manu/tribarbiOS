//
//  EmployeeBookingViewController.swift
//  tribarb
//
//  Created by Anith Manu on 21/11/2020.
//

import UIKit
import SwiftyJSON

class EmployeeBookingViewController: UIViewController {

    @IBOutlet weak var lbBookingType: UILabel!
    @IBOutlet weak var lbBookingDate: UILabel!
    @IBOutlet weak var lbCustomer: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbStatus: UILabel!
    
    @IBOutlet weak var mapView: UIView!
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
    var phone = ""
    var bookedServices = [JSON]()
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.addressView.isHidden = true
        self.mapView.isHidden = true
        
        self.imgAvatar.layer.cornerRadius = 75/2
        self.imgAvatar.layer.borderWidth = 1.0
        self.imgAvatar.layer.borderColor = UIColor.white.cgColor
        self.imgAvatar.clipsToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBooking()
    }
    
    
    func getBooking() {
        Helpers.showBookingActivityIndicator(activityIndicator, view)
        print(bookingId!)
        APIManager.shared.getBooking(bookingID: bookingId!) { (json) in
            print(json)
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
        }
        

        if booking.status == "Completed" || booking.status == "Cancelled" || booking.status == "Declined"  {
            self.mapView.isHidden = true
            self.buttonsView.isHidden = true
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
