//
//  ServiceListViewController.swift
//  tribarb
//
//  Created by Anith Manu on 29/11/2020.
//

import UIKit
import CoreLocation
import MapKit


class ServiceListViewController: UIViewController {
    
    @IBOutlet weak var shopLogo: UIImageView!
    @IBOutlet weak var lbShopName: UILabel!
    @IBOutlet weak var lbShopAddress: UILabel!
    @IBOutlet weak var btShopIg: UIButton!
    @IBOutlet weak var btShopFb: UIButton!
    @IBOutlet weak var btShopPhone: UIButton!
    @IBOutlet weak var btShopOnMap: UIButton!
    @IBOutlet var tbvServices: UITableView!

    @IBOutlet weak var shopInfoView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var coverHeightConstraint: NSLayoutConstraint!
    var previousOffsetState: CGFloat = 0
    

    @IBOutlet weak var lbRating: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var lbNumberOfRatings: UILabel!
    
    static var lastFractionComplete: CGFloat = 0
    
    var comingFromRoot: Bool = false
    
    var shop: Shop?
    var ig = ""
    var fb = ""
    var phone = ""
    var services = [Service]()
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ratingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        ratingView.layer.cornerRadius = 10
        
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
        
        

        var rating: Float = 0.0
        if shop?.numberOfRatings! != 0 {
            rating = ((shop?.totalRating)!/(shop?.numberOfRatings)!)
        }
        lbRating.text = String(format: "%.1f", rating)
        lbNumberOfRatings.text = "\(Int((shop?.numberOfRatings)!)) ratings"
        
        
        loadServices()
    }
    
    
    
    func addTopAndBottomBorders() {
       let thickness: CGFloat = 0.3
       let bottomBorder = CALayer()

       bottomBorder.frame = CGRect(x:0, y: self.shopInfoView.frame.size.height - thickness, width: self.shopInfoView.frame.size.width, height:thickness)
       bottomBorder.backgroundColor = UIColor.lightGray.cgColor

        shopInfoView.layer.addSublayer(bottomBorder)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        addTopAndBottomBorders()
        
        
        
        blurView.effect = .none
        setupBlur()



        if comingFromRoot == true {
            animator.fractionComplete = 0
        } else {
            animator.fractionComplete = ServiceListViewController.lastFractionComplete
        }
        comingFromRoot = false
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ServiceDetails" {
            let controller = segue.destination as! ServiceDetailsViewController
            controller.service = services[(tbvServices.indexPathForSelectedRow?.row)!]
            controller.shop = shop
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        animator.startAnimation()
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .current)
    }
    
    
    
    
    
    
    func loadServices() {

        Helpers.showWhiteOutActivityIndicator(activityIndicator, view)
        
        if let shopId = shop?.id {
            APIManager.shared.getServices(filterID: ShopViewController.BOOKING_TYPE_VAR, shopID: shopId) { (json) in
                if json != nil {
                    self.services = []
                    
                    if let tempServices = json?["services"].array {
                        
                        for item in tempServices {
                            let service = Service(json: item)
                            self.services.append(service)
                        }
                        self.tbvServices.reloadData()
                    }
                    Helpers.hideActivityIndicator(self.activityIndicator)
   
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
    
    
    @IBAction func openMaps(_ sender: Any) {
        
        guard let address = shop?.address else {
            return
        }
        
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                return
            }
            
            // Use your location
            let regionDistance: CLLocationDistance = 1000
            let coordinates = location.coordinate
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                
            let placemark = MKPlacemark(coordinate: coordinates)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.shop?.name
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    
    var animator: UIViewPropertyAnimator!
    fileprivate func setupBlur() {
        animator = UIViewPropertyAnimator(duration: 3.0, curve: .linear, animations: {
            let blurEffect = UIBlurEffect(style: .regular)
            self.blurView.effect = blurEffect

        })
    }
    
    

}



extension ServiceListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceTableViewCell
        
        let service = services[indexPath.row]
        cell.lbServiceName.text = service.name
        cell.lbServiceShortDescription.text = service.short_description
    
        
        if let price = service.price {
            cell.lbServicePrice.text = "£\(price)"
        }
    
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        animator.fractionComplete = abs(scrollView.contentOffset.y)/100
        
        ServiceListViewController.lastFractionComplete = animator.fractionComplete
        
        let offsetDiff = previousOffsetState - scrollView.contentOffset.y
        previousOffsetState = scrollView.contentOffset.y
        let newHeight = coverHeightConstraint.constant + offsetDiff
        coverHeightConstraint.constant = newHeight
        
        
    }
}
