//
//  ServiceListTableViewController.swift
//  tribarb
//
//  Created by Anith Manu on 19/10/2020.
//

import UIKit

class ServiceListTableViewController: UITableViewController {
    
    @IBOutlet weak var shopLogo: UIImageView!
    @IBOutlet weak var lbShopName: UILabel!
    @IBOutlet weak var lbShopAddress: UILabel!
    @IBOutlet weak var btShopIg: UIButton!
    @IBOutlet weak var btShopFb: UIButton!
    @IBOutlet weak var btShopPhone: UIButton!
    @IBOutlet var tbvServices: UITableView!
    
    var shop: Shop?
    var ig = ""
    var fb = ""
    var phone = ""
    var services = [Service]()
    let activityIndicator = UIActivityIndicatorView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ShopViewController.BOOKING_TYPE_VAR == 0 {
            self.navigationItem.title = "Shop Services"
        } else {
            self.navigationItem.title = "Home Services"
        }
 
        if let imageUrl = shop?.logo {
            Helpers.loadImage(shopLogo, "\(imageUrl)")
        }
        
        self.lbShopName.text = shop?.name
        self.lbShopAddress.text = shop?.address
        ig = (self.shop?.instagram)!
        fb = (self.shop?.facebook)!
        phone = (self.shop?.phone)!
        
        if ig == "" {
            btShopIg.isHidden = true
        }
        
        if fb == "" {
            btShopFb.isHidden = true
        }
        
        loadServices()
    }
    
    
    
    func loadServices() {
        Helpers.showActivityIndicator(activityIndicator, view)
        
        if let shopId = shop?.id {
            
            if ShopViewController.BOOKING_TYPE_VAR == 0 {
                APIManager.shared.getShopServices(shopID: shopId) { (json) in
                    
                    if json != nil {
                        self.services = []
                        
                        if let tempServices = json?["services"].array {
                            
                            for item in tempServices {
                                let service = Service(json: item)
                                self.services.append(service)
                            }
                            self.tableView.reloadData()
                            Helpers.hideActivityIndicator(self.activityIndicator)
                        }
                    }
                }
            } else {
                APIManager.shared.getHomeServices(shopID: shopId) { (json) in
                    
                    if json != nil {
                        self.services = []
                        
                        if let tempServices = json?["services"].array {
                            
                            for item in tempServices {
                                let service = Service(json: item)
                                self.services.append(service)
                            }
                            self.tableView.reloadData()
                            Helpers.hideActivityIndicator(self.activityIndicator)
                        }
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func openIG(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.instagram.com/\(ig)")!)
    }
    
    
    
    @IBAction func openFB(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.facebook.com/\(fb)")!)
    }
    
    
    
    @IBAction func call(_ sender: Any) {
        
        if let phoneCallURL = URL(string: "tel://\(phone)") {
            let application:UIApplication = UIApplication.shared
            
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
          }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ServiceDetails" {
            let controller = segue.destination as! ServiceDetailsViewController
            controller.service = services[(tableView.indexPathForSelectedRow?.row)!]
            controller.shop = shop
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceTableViewCell
        
        let service = services[indexPath.row]
        cell.lbServiceName.text = service.name
        cell.lbServiceShortDescription.text = service.short_description
        
        if let price = service.price {
            cell.lbServicePrice.text = "£\(price)"
        }
        return cell
        
    }
    

    
    
    
    
}
