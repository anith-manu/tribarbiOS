//
//  EmployeeBookingsViewController.swift
//  tribarb
//
//  Created by Anith Manu on 18/11/2020.
//

import UIKit
import SkeletonView

class EmployeeBookingsViewController: UIViewController {
    
    @IBOutlet weak var tbvBookings: UITableView!
    @IBOutlet weak var filterBookings: UISegmentedControl!
    @IBOutlet weak var loadingView: UIView!
    var bookings = [Booking]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setEmployeeDetails()
        self.navigationItem.title = "Bookings"
        beamsClient.registerForRemoteNotifications()
        tabbarConfig()
    }
    
    
    func setEmployeeDetails() {
        APIManager.shared.employeeGetDetails { (json) in
            if json != nil {
                User.currentUser.setEmployeeInfo(json: json!)
                Helpers.setUserIDBeams(email: User.currentUser.email ?? "")
        
                self.navigationItem.prompt = User.currentUser.shop
                self.loadBookings()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadBookings()
    }
    

    func loadBookings() {
        
        self.showLoadingSkeleton()
        APIManager.shared.employeeGetBookings(filterID: filterBookings.selectedSegmentIndex) { (json) in
            
            
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
    
    
    func tabbarConfig() {
        guard let tabbar = self.tabBarController?.tabBar else { return }
        tabbar.layer.cornerRadius = 30
        tabbar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabbar.layer.masksToBounds = true
        tabbar.barTintColor = .black
        tabbar.tintColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BookingDetail" {
            let controller = segue.destination as! EmployeeBookingViewController
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
    

    @IBAction func switchBookingType(_ sender: Any) {
        loadBookings()
    }
}




extension EmployeeBookingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! EmployeeBookingTableViewCell
        
        let booking: Booking
        
       
        booking = bookings[indexPath.row]
        
        if booking.booking_type == 1 {
            cell.lbBookingType.text = "Home Booking"
        } else {
            cell.lbBookingType.text = "Shop Booking"
        }
        
        cell.lbCustomer.text = booking.customer!
        
        cell.lbStatus.text = booking.status
        cell.lbStatus.layer.cornerRadius = 10
        cell.lbStatus.layer.masksToBounds = true
        cell.lbBarberName.text = booking.employee_name
        cell.barberView.isHidden = false
        
        if booking.status == "Placed" {
            cell.barberView.isHidden = true
            cell.lbStatus.backgroundColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        } else if booking.status == "Accepted" || booking.status == "Completed" || booking.status == "Barber En Route" {
            cell.lbStatus.backgroundColor = UIColor(red: 0.23, green: 0.65, blue: 0.00, alpha: 1.00)
        } else if booking.status == "Cancelled" || booking.status == "Declined" {
            cell.lbStatus.backgroundColor = .systemRed
            
            if booking.status == "Cancelled" {
                cell.barberView.isHidden = true
            }
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
