//
//  ShopViewController.swift
//  tribarb
//
//  Created by Anith Manu on 19/10/2020.
//

import UIKit
import SwiftUI

class ShopViewController: UIViewController, UISearchResultsUpdating {
    
    
    static var BOOKING_TYPE_VAR = 0
    var shops = [Shop]()
    var filteredShops = [Shop]()
    @IBOutlet weak var tbvShops: UITableView!
    @IBOutlet weak var booking_type: UISegmentedControl!
    let activityIndicator = UIActivityIndicatorView()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    var segmentedController: UISegmentedControl!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        load_shops()
        tabbarConfig()
        setupNavBar()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
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
    
    
    
    fileprivate func setupNavBar() {
        
        if #available(iOS 11.0, *) {
                navigationItem.hidesSearchBarWhenScrolling = false
            }
    
        
        searchController.searchBar.tintColor = .black
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Barbershops", attributes: [NSAttributedString.Key.foregroundColor : UIColor(rgb:0x000000)])
        
        let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor(rgb:0x000000)
        let clearButton = textField.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor(rgb:0x000000)
        
        
        navigationItem.searchController = searchController
        
        

        let fullLogoImageView = UIImageView(image: UIImage(named: "tribarb_text"))
        fullLogoImageView.contentMode = .scaleAspectFit
        fullLogoImageView.width(100)

        navigationItem.titleView = fullLogoImageView
    }
    
    
    func tabbarConfig() {
        guard let tabbar = self.tabBarController?.tabBar else { return }
        tabbar.layer.cornerRadius = 30
        tabbar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabbar.layer.masksToBounds = true
        tabbar.barTintColor = .black
        tabbar.tintColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
    }
    
    
    
    
    func load_shops() {
        
        shops = []
        
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
                self.load_shops()
                self.viewWillAppear(true)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                self.booking_type.selectedSegmentIndex = ShopViewController.BOOKING_TYPE_VAR ;
            }
            
            alertView.addAction(okAction)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true, completion: nil)
            
        } else if Cart.currentCart.items.isEmpty {
            load_shops()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ServiceList" {
            let controller = segue.destination as! ServiceListViewController
            if searchController.searchBar.text != "" {
                controller.shop = filteredShops[(tbvShops.indexPathForSelectedRow?.row)!]
            } else {
                controller.shop = shops[(tbvShops.indexPathForSelectedRow?.row)!]
            }
            controller.comingFromRoot = true
    
        }
    }
    
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredShops = self.shops.filter({ (bar: Shop) -> Bool in
            return bar.name?.lowercased().range(of: text.lowercased()) != nil
        })
        self.tbvShops.reloadData()
    }
    
    
 
}








extension ShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.searchBar.text != "" {
            return self.filteredShops.count
        }
        return self.shops.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell", for: indexPath) as! ShopTableViewCell
        cell.mainBackground.layer.cornerRadius = 15
        cell.mainBackground.layer.masksToBounds = true
        cell.shadowLayer.setupShadow()
        
        cell.ratingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cell.ratingView.layer.cornerRadius = 15
        cell.ratingView.layer.masksToBounds = true


        let shop: Shop
      
        if searchController.searchBar.text != "" {
            shop = filteredShops[indexPath.row]
        } else {
            shop = shops[indexPath.row]
        }
        
       
        var rating: Float = 0.0
        if shop.numberOfRatings! != 0 {
            rating = ((shop.totalRating!)/(shop.numberOfRatings!))
        }
        cell.lbRating.text = String(format: "%.1f", rating)
        cell.lbNumberOfRatings.text = "\(Int(shop.numberOfRatings!)) ratings"

        
        cell.lbShopName.text = shop.name!
        cell.lbShopAddress.text = shop.address!
        
        
        if let logoName = shop.logo {
            cell.shopLogo.loadImage("\(logoName)")
            cell.shopLogo.contentMode = .scaleAspectFill
        }
        return cell
    }
}


