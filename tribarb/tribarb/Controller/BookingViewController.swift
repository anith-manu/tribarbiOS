//
//  BookingViewController.swift
//  tribarb
//
//  Created by Anith Manu on 09/11/2020.
//

import UIKit
import SwiftyJSON

class BookingViewController: UIViewController {

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
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var barberView: UIView!
    @IBOutlet weak var tbvServices: UITableView!
    
    var cart = [JSON]()
    var phone = ""
    
    var booking: Booking?
    
    var fromController: Int = 0
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if fromController == 1 {
            getLatestBooking()
            let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
            navigationItem.leftBarButtonItem = backButton
        } else {
            getBooking()
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    
    func getBooking() {
        Helpers.showActivityIndicator(activityIndicator, view)
    
        if let bookingID = booking?.id {
            APIManager.shared.getBooking(bookingID: bookingID) { (json) in
                
                self.setUIElements(json: json!)
                Helpers.hideActivityIndicator(self.activityIndicator)
            }
        }
    }
    
    
    func getLatestBooking() {
        
        APIManager.shared.getLatestBooking { (json) in
            
            self.setUIElements(json: json!)
        }
    }
    

    
    func setUIElements(json: JSON) {
        
        let booking = json["booking"]
    
        if booking["status"] != nil {
            self.title = "Booking #\(booking["id"])"
            //\(booking["id"])
            self.lbShopName.text = booking["shop"]["name"].string!
            
            var bookingType = ""
            if booking["booking_type"] == 1 {
                bookingType = "Home booking"
                self.lbAddressType.text = "Home Address : "
                self.lbAddress.text = "\(booking["address"])"
            } else {
                bookingType = "Shop booking"
                self.lbAddressType.text = "Shop Address : "
                self.lbAddress.text = "\(booking["shop"]["address"])"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
            let date = dateFormatter.date(from: booking["requested_time"].string!)
            dateFormatter.dateFormat = "d MMM y, HH:mm"
        
            self.lbBookingType.text = bookingType + " on " + dateFormatter.string(from: date!)
            

            let employee = "\(booking["employee"])"
            if employee == "null" {
                self.barberView.isHidden = true
            } else {
                self.barberView.isHidden = false
                self.lbBarberName.text = "\(booking["employee"]["name"])"
                
                if "\(booking["employee"]["phone"])" != "" {
                    self.phone = "\(booking["employee"]["phone"])"
                } else {
                    self.phone = "\(booking["shop"]["phone"])"
                }
            }
            
            if let bookingDetails = booking["booking_details"].array {
                self.lbStatus.text = booking["status"].string!.uppercased()
                self.cart = bookingDetails
                self.tbvServices.reloadData()
            }
            
            let requests = "\(booking["requests"])"
    
            if requests == "" || requests == "null" {
                self.requestView.isHidden = true
            } else {
                self.requestView.isHidden = false
                self.lbRequest.text = requests
            }
            
            
            if booking["payment_mode"] == 0 {
                self.lbPaymentMethod.text = "Cash"
            } else {
                self.lbPaymentMethod.text = "Card"
            }
            
            if "\(booking["status"])" != "Placed" {
                self.cancelView.isHidden = true
            } else {
                self.cancelView.isHidden = false
            }
            
            if "\(booking["status"])" == "Completed" || "\(booking["status"])" == "Cancelled" || "\(booking["status"])" == "Declined"  {
                self.mapView.isHidden = true
            } else {
                self.mapView.isHidden = false
            }
            
            // SERVICE FEE MODIFY HERE
            self.lbSubTotal.text = "£\(String(booking["total"].float! - 1.5))"
            self.lbTotal.text = "£\(String(booking["total"].float!))"
        }
        
    }
    
    
    
    @IBAction func callBarber(_ sender: Any) {
        if let phoneCallURL = URL(string: "tel://\(phone)") {
            let application:UIApplication = UIApplication.shared
            
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
          }
    }
    
    
    @IBAction func cancelBooking(_ sender: Any) {
    }
}


extension BookingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! BookingTableViewCell
        
        let item = cart[indexPath.row]

        cell.lbServiceName.text = item["service"]["service_name"].string
        cell.lbServicePrice.text = "£\(String(item["sub_total"].float!))"
        
        return cell
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
