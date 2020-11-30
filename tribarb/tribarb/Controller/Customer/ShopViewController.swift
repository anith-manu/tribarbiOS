//
//  ShopViewController.swift
//  tribarb
//
//  Created by Anith Manu on 19/10/2020.
//

import UIKit

class ShopViewController: UIViewController {
    

    static var BOOKING_TYPE_VAR = 0
    var shops = [Shop]()
    var filteredShops = [Shop]()
    @IBOutlet weak var tbvShops: UITableView!
    @IBOutlet weak var booking_type: UISegmentedControl!
    @IBOutlet weak var searchShops: UISearchBar!
    let activityIndicator = UIActivityIndicatorView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load_shops()
        tabbarConfig()
    }
    
    
    func tabbarConfig() {
        guard let tabbar = self.tabBarController?.tabBar else { return }
        tabbar.layer.cornerRadius = 30
        tabbar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabbar.layer.masksToBounds = true
        tabbar.barTintColor = .black
        tabbar.tintColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if Cart.currentCart.items.isEmpty {
            self.tabBarController?.tabBar.items?[1].isEnabled = false
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
        }
        
    

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
    
    
    
    func load_shops() {
        Helpers.showActivityIndicator(activityIndicator, view)
        ShopViewController.BOOKING_TYPE_VAR = booking_type.selectedSegmentIndex
        
        APIManager.shared.get_shops(filterID:  ShopViewController.BOOKING_TYPE_VAR) { (json) in
            if json != nil {
                self.shops = []
                
                if let listBarber = json?["shops"].array {
                    
                    for item in listBarber {
                        let shop = Shop(json: item)
                        self.shops.append(shop)
                    }
                    self.tbvShops.reloadData()
                    Helpers.hideActivityIndicator(self.activityIndicator)
                }
            }
        }
    }


     
    @IBAction func switch_booking_type(_ sender: Any) {
        
        if Cart.currentCart.items.isEmpty == false && Cart.currentCart.bookingType != booking_type.selectedSegmentIndex  {
            let bookingTypeString = booking_type.titleForSegment(at: booking_type.selectedSegmentIndex)!
            
            let alertView = UIAlertController(
                title: "Clear Cart?",
                message: "Would you like to clear current cart and start a new \(bookingTypeString)?",
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Start \(bookingTypeString)", style: .destructive) { (action: UIAlertAction!) in
                Cart.currentCart.reset()
                self.tabBarController?.tabBar.items?[1].isEnabled = false
                self.tabBarController?.tabBar.items?[1].badgeValue = nil
                self.shops.removeAll()
                self.tbvShops.reloadData()
                self.load_shops()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                self.booking_type.selectedSegmentIndex = ShopViewController.BOOKING_TYPE_VAR ;
            }
            
            alertView.addAction(okAction)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true, completion: nil)
            
        } else if Cart.currentCart.items.isEmpty {
            shops.removeAll()
            tbvShops.reloadData()
            load_shops()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ServiceList" {
            let controller = segue.destination as! ServiceListViewController
            controller.shop = shops[(tbvShops.indexPathForSelectedRow?.row)!]
        }
    }
 
}





extension ShopViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredShops = self.shops.filter({ (bar: Shop) -> Bool in
            return bar.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        self.tbvShops.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}





extension ShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchShops.text != "" {
            return self.filteredShops.count
        }
        return self.shops.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell", for: indexPath) as! ShopTableViewCell
        cell.mainBackground.layer.cornerRadius = 20
        cell.mainBackground.layer.masksToBounds = true
        cell.shadowLayer.setupShadow()


        let shop: Shop
      
        if searchShops.text != "" {
            shop = filteredShops[indexPath.row]
        } else {
            shop = shops[indexPath.row]
        }
        
        if shop.totalRating! == 0 {
            cell.ratingView.isHidden = true
            cell.lbNewlyAdded.isHidden = false
        } else {
            cell.ratingView.isHidden = false
            cell.lbNewlyAdded.isHidden = true
            let rating = ((shop.totalRating!)/(shop.numberOfRatings!))
            cell.lbRating.text = String(format: "%.1f", rating)
            cell.lbNumberOfRatings.text = "(\(Int(shop.numberOfRatings!)))"
        }
        
        cell.lbShopName.text = shop.name!
        cell.lbShopAddress.text = shop.address!
        
        if let logoName = shop.logo {
            Helpers.loadImage(cell.shopLogo, "\(logoName)")
        }
        return cell
    }
}


class ShadowView: UIView {

    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    
    func setupShadow() {
        self.layer.cornerRadius = 20
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 4
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.33
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
