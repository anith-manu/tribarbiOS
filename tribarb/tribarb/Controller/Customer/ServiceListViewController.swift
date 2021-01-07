//
//  ServiceListViewController.swift
//  tribarb
//
//  Created by Anith Manu on 29/11/2020.
//

import UIKit
import CoreLocation
import MapKit
import SkeletonView


class ServiceListViewController: UIViewController {
    
    @IBOutlet weak var shopLogo: CustomImageView!
    @IBOutlet weak var btShopIg: UIButton!
    @IBOutlet weak var btShopFb: UIButton!
    @IBOutlet weak var btShopPhone: UIButton!
    @IBOutlet weak var btShopOnMap: UIButton!
    @IBOutlet var tbvServices: UITableView!
    @IBOutlet weak var shopInfoView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var coverHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lbRating: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var lbNumberOfRatings: UILabel!
    @IBOutlet weak var lbServicesType: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    static var lastFractionComplete: CGFloat = 0
    var comingFromRoot: Bool = false
    var shop: Shop?
    var ig = ""
    var fb = ""
    var phone = ""
    var services = [Service]()
    var bookedServices = [Service]()
    var previousOffsetState: CGFloat = 0
    var animator: UIViewPropertyAnimator!
    let activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        setServiceListUI()
        getBookedServices()
        loadServices()
        setGradientBackground()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBlur()
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
    
    
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.shopInfoView.bounds
        gradientLayer.colors = [UIColor(rgb: 0xFFC15D).cgColor, UIColor(rgb: 0xFFC15D).cgColor, UIColor(rgb: 0xFFC15D).cgColor, UIColor(rgb: 0xffd590).cgColor, UIColor(rgb: 0xffdeaa).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.shopInfoView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func setServiceListUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = shop?.name
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        ratingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        ratingView.layer.cornerRadius = 10
        
        if ShopViewController.BOOKING_TYPE_VAR == 0 {
            self.lbServicesType.text = "Shop Services"
        } else {
            self.lbServicesType.text = "Home Services"
        }
        
        if let imageUrl = shop?.logo {
            shopLogo.loadImage("\(imageUrl)")
            shopLogo.contentMode = .scaleAspectFill
        }

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
    }
    
    
    func getBookedServices() {
        for item in Cart.currentCart.items {
            bookedServices.append(item.service)
        }
    }
    
    
    
    func loadServices() {
        self.loadingView.isSkeletonable = true
        self.loadingView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: UIColor(rgb: 0xEEEEEF)), animation: nil, transition: .crossDissolve(0.25))
        
        if let shopId = shop?.id {
            APIManager.shared.getServices(filterID: ShopViewController.BOOKING_TYPE_VAR, shopID: shopId) { (json) in
                if json != nil {
                    self.services = []
                    
                    if let tempServices = json?["services"].array {
                        
                        for item in tempServices {
                            let service = Service(json: item)
                            self.services.append(service)
                        }
                        
                        
                        self.loadingView.isHidden = true
                        self.loadingView.stopSkeletonAnimation()
                        self.loadingView.hideSkeleton()
                    
                        self.tbvServices.reloadData()
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
    
    
    fileprivate func setupBlur() {
        blurView.effect = .none
        animator = UIViewPropertyAnimator(duration: 3.0, curve: .linear, animations: {
            let blurEffect = UIBlurEffect(style: .regular)
            self.blurView.effect = blurEffect

        })
        
        if comingFromRoot == true {
            animator.fractionComplete = 0
        } else {
            animator.fractionComplete = ServiceListViewController.lastFractionComplete
        }
        comingFromRoot = false
    }
    
}



extension ServiceListViewController: UITableViewDelegate, SkeletonTableViewDataSource {
    
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ServiceCell"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceTableViewCell
        
        cell.isSkeletonable = true
        
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


