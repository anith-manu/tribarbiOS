//
//  ShopViewController.swift
//  tribarb
//
//  Created by Anith Manu on 19/10/2020.
//

import UIKit
import SkeletonView

class BookingsViewController: UIViewController {

    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var tbvBookings: UITableView!
    var filter_bookings_var = 0
    var bookings = [Booking]()
    
    @IBOutlet weak var filterBookings: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        load_bookings()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            APIManager.shared.customerGetBookings(filterID: 0) { (json) in
                if json == nil || json!["bookings"].isEmpty {
                    self.tabBarController?.tabBar.items?[2].badgeValue = nil
                } else {
                    self.tabBarController?.tabBar.items?[2].badgeValue = ""
                }
            }
        }
    }
    
    
    
    func load_bookings() {
    
        self.showLoadingSkeleton()

        filter_bookings_var = filterBookings.selectedSegmentIndex
        
        APIManager.shared.customerGetBookings(filterID: filter_bookings_var) { (json) in
            if json != nil {
                
                self.bookings = []
                
                if let listBarber = json?["bookings"].array {
                    for item in listBarber {

                        let booking = Booking(json: item)
                        self.bookings.append(booking)
                    }
                    
                    self.hideLoadingSkeleton()
                    self.tbvBookings.reloadData()
                
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
            controller.booking = bookings[(tbvBookings.indexPathForSelectedRow?.row)!]
        }
    }
    
    
    func showLoadingSkeleton() {
        self.loadingView.isHidden = false
        self.loadingView.isSkeletonable = true
        self.loadingView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: UIColor(rgb: 0xEEEEEF)), animation: nil, transition: .crossDissolve(0.25))
    }
    
    func hideLoadingSkeleton() {
        self.loadingView.isHidden = true
        self.loadingView.stopSkeletonAnimation()
        self.loadingView.hideSkeleton()
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
        
        let booking: Booking
        
       
        booking = bookings[indexPath.row]
        
        cell.lbShopName.text = booking.shopName
        
        if booking.booking_type == 1 {
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
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
        let date = dateFormatter.date(from: booking.date!)
        dateFormatter.dateFormat = "d MMM y, HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        cell.lbBookingDate.text = dateFormatter.string(from: date!)
        
        return cell
    }
    
    
    
}
