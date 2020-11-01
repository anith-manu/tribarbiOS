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
        self.tbvShops.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.00)
        self.booking_type.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        self.booking_type.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.00)

        load_shops()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    
    func load_shops() {
        Helpers.showActivityIndicator(activityIndicator, view)
        
        ShopViewController.BOOKING_TYPE_VAR = booking_type.selectedSegmentIndex
        
        if ShopViewController.BOOKING_TYPE_VAR == 0 {
            
            APIManager.shared.get_shop_booking_shops { (json) in
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
        } else {
            
            APIManager.shared.get_home_booking_shops { (json) in
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
        
        
    }


     
    @IBAction func switch_booking_type(_ sender: Any) {
        
        if Cart.currentCart.items.isEmpty == false && Cart.currentCart.bookingType != booking_type.selectedSegmentIndex  {
            let bookingTypeString = booking_type.titleForSegment(at: booking_type.selectedSegmentIndex)!
            
            
            let alertView = UIAlertController(
                title: "Clear Cart?",
                message: "Would you like to clear current cart and start a new \(bookingTypeString)?",
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Start \(bookingTypeString)", style: .default) { (action: UIAlertAction!) in
                Cart.currentCart.reset()
                
                self.shops.removeAll()
                self.tbvShops.reloadData()
                self.load_shops()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
                print(ShopViewController.BOOKING_TYPE_VAR)
                self.booking_type.selectedSegmentIndex = ShopViewController.BOOKING_TYPE_VAR ;
            }
            
            alertView.addAction(okAction)
            alertView.addAction(cancelAction)
            
            self.present(alertView, animated: true, completion: nil)
        } else if Cart.currentCart.items.isEmpty {
            print("called")
            shops.removeAll()
            tbvShops.reloadData()
            load_shops()
        }
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ServiceList" {
            let controller = segue.destination as! ServiceListTableViewController
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
        cell.selectionStyle = .none
        let shop: Shop
        
        if searchShops.text != "" {
            shop = filteredShops[indexPath.row]
        } else {
            shop = shops[indexPath.row]
        }
        
        cell.lbShopName.text = shop.name!
        cell.lbShopAddress.text = shop.address!
        
        if let logoName = shop.logo {
            Helpers.loadImage(cell.shopLogo, "\(logoName)")
            
        }
        
        return cell
    }
}

