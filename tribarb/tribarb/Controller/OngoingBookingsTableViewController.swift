//
//  OngoingBookingsTableViewController.swift
//  tribarb
//
//  Created by Anith Manu on 21/10/2020.
//

import UIKit
import SwiftyJSON

class OngoingBookingsTableViewController: UITableViewController {
    
    @IBOutlet weak var lbShopName: UILabel!
    @IBOutlet weak var lbBookingType: UILabel!
    @IBOutlet weak var lbBookingStatus: UILabel!
    @IBOutlet weak var lbAddressType: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var assignedBarber: UIView!
    @IBOutlet weak var barberName: UILabel!
    @IBOutlet weak var barberPhone: UIButton!
    @IBOutlet weak var lbSubTotal: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var instructions: UIView!
    @IBOutlet weak var lbInstructions: UILabel!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var lbPaymentMethod: UILabel!
    @IBOutlet weak var cancel: UIButton!
    
    var cart = [JSON]()
    var phone = ""
    
    var fromController: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if fromController == 1 {
            getLatestBooking()
            let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
            navigationItem.leftBarButtonItem = backButton
        } else {
            getLatestBooking()
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    
    func getLatestBooking() {
        
        APIManager.shared.getLatestBooking { (json) in
            
            let booking = json!["booking"]
            
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
                    self.assignedBarber.isHidden = true
                } else {
                    self.assignedBarber.isHidden = false
                    self.barberName.text = "\(booking["employee"]["name"])"
                    
                    if "\(booking["employee"]["phone"])" != "" {
                        self.phone = "\(booking["employee"]["phone"])"
                    } else {
                        self.phone = "\(booking["shop"]["phone"])"
                    }
                }
                
                if let bookingDetails = booking["booking_details"].array {
                    self.lbBookingStatus.text = booking["status"].string!.uppercased()
                    self.cart = bookingDetails
                    self.tableView.reloadData()
                }
                
                let requests = "\(booking["requests"])"
                print(requests)
                if requests == "" || requests == "null" {
                    self.instructions.isHidden = true
                } else {
                    self.instructions.isHidden = false
                    self.lbInstructions.text = requests
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
                
                // SERVICE FEE MODIFY HERE
                self.lbSubTotal.text = "£\(String(booking["total"].float! - 1.5))"
                self.lbTotal.text = "£\(String(booking["total"].float!))"
            }
        }
    }

    @IBAction func call(_ sender: Any) {
        
        if let phoneCallURL = URL(string: "tel://\(phone)") {
            let application:UIApplication = UIApplication.shared
            
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
          }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! BookingTableViewCell
        
        let item = cart[indexPath.row]
        cell.lbServiceName.text = item["service"]["service_name"].string
        cell.lbServicePrice.text = "£\(String(item["sub_total"].float!))"
        
        return cell
    }


}
