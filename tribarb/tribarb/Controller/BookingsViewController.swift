//
//  ShopViewController.swift
//  tribarb
//
//  Created by Anith Manu on 19/10/2020.
//

import UIKit

class BookingsViewController: UIViewController {

    
    @IBOutlet weak var tbvBookings: UITableView!
    var filter_bookings_var = 0
    let activityIndicator = UIActivityIndicatorView()
    var bookings = [Bookings]()
    
    @IBOutlet weak var filterBookings: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        load_bookings()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            APIManager.shared.getUpcomingBookings { (json) in
    
                if json == nil || json!["bookings"].isEmpty {
                    self.tabBarController?.tabBar.items?[2].badgeValue = nil
                } else {
                    self.tabBarController?.tabBar.items?[2].badgeValue = ""
                }
            }
        }
    }
    
    
    

    
    
    func load_bookings() {
        Helpers.showActivityIndicator(activityIndicator, view)
        filter_bookings_var = filterBookings.selectedSegmentIndex
        
        if filter_bookings_var == 0 {
            APIManager.shared.getUpcomingBookings { (json) in
        
                if json != nil {
                    
                    self.bookings = []
                    
                    if let listBarber = json?["bookings"].array {
                        for item in listBarber {
    
                            let booking = Bookings(json: item)
                            self.bookings.append(booking)
                        }
                        self.tbvBookings.reloadData()
                        Helpers.hideActivityIndicator(self.activityIndicator)
                    }
                } 
            }
        } else {
            APIManager.shared.getPastBookings { (json) in
                
                if json != nil {
                    
                    self.bookings = []
                    
                    if let listBarber = json?["bookings"].array {
                        for item in listBarber {
                            let booking = Bookings(json: item)
                            self.bookings.append(booking)
                        }
                        self.tbvBookings.reloadData()
                        Helpers.hideActivityIndicator(self.activityIndicator)
                    }
                }
            }
        }
    }
    
    
    @IBAction func switchBookingsFilter(_ sender: Any) {
        load_bookings()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "BookingDetail" {
            let controller = segue.destination as! BookingViewController
            controller.bookingId = bookings[(tbvBookings.indexPathForSelectedRow?.row)!].id
        }
    }
}



extension BookingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! FilterBookingTableViewCell
        
        let booking: Bookings
        
       
        booking = bookings[indexPath.row]
        
        cell.lbShopName.text = booking.shopName
        
        if booking.booking_type == "1" {
            cell.lbBookingType.text = "Home Booking"
        } else {
            cell.lbBookingType.text = "Shop Booking"
        }
        
        
        cell.lbStatus.text = booking.status
        cell.lbStatus.layer.cornerRadius = 10
        cell.lbStatus.layer.masksToBounds = true
        
        if booking.status == "Placed" {
            cell.lbStatus.backgroundColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        } else if booking.status == "Accepted" || booking.status == "Completed" || booking.status == "Barber En Route" {
            cell.lbStatus.backgroundColor = UIColor(red: 0.23, green: 0.65, blue: 0.00, alpha: 1.00)
        } else if booking.status == "Cancelled" || booking.status == "Declined" {
            cell.lbStatus.backgroundColor = .systemRed
        }
        
        let dateFormatter = DateFormatter()
  //      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
        let date = dateFormatter.date(from: booking.date!)
        dateFormatter.dateFormat = "d MMM y, HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        cell.lbBookingDate.text = dateFormatter.string(from: date!)
        
        return cell
    }
    
    
    
}
