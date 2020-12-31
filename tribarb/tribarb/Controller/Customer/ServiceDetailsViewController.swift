//
//  ServiceDetailsViewController.swift
//  tribarb
//
//  Created by Anith Manu on 19/10/2020.
//

import UIKit


class ServiceDetailsViewController: UIViewController {

    @IBOutlet weak var serviceImagesCV: UICollectionView!
    @IBOutlet weak var lbServiceName: UILabel!
    @IBOutlet weak var lbServiceShortDescription: UILabel!
    @IBOutlet weak var lbServicePrice: UILabel!
    @IBOutlet weak var addService: CurvedButton!
    
    var service: Service?
    var shop: Shop?
    var urls = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        serviceImagesCV.isHidden = true
        serviceImagesCV.frame = .zero
        serviceImagesCV.collectionViewLayout = layout
        serviceImagesCV.translatesAutoresizingMaskIntoConstraints = false
        serviceImagesCV.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        serviceImagesCV.backgroundColor = .white
        
        
        if checkServiceInCart() {
            setAddedToCartButton()
        }
        loadService()
        loadAlbum()
       
    }
    

    func checkServiceInCart() -> Bool {
        let cartItem = CartItem(service: self.service!)
        
        let inCart = Cart.currentCart.items.firstIndex { (item) -> Bool in
            return item.service.id! == cartItem.service.id!
        }
        
        if inCart != nil {
            return true
        } else {
            return false
        }
    }
    
    func setAddedToCartButton() {
        addService.setTitle("Booked", for: .normal)
        addService.isEnabled = false
        addService.layer.opacity = 0.55
    }
    
    
    
    func loadService() {
        lbServiceName.text = service?.name
        lbServiceShortDescription.text = service?.short_description
        
        if let price = service?.price {
            lbServicePrice.text = "£\(price)"
        }
    }
    
    
    
    func loadAlbum() {
        
        if let serviceId = service?.id {
            APIManager.shared.getServiceAlbum(serviceID: serviceId) { (json) in
           
                if json != nil {
                    
                    if let tempServices = json?["album"].array {
                        
                        if tempServices.count > 0 {
                            self.serviceImagesCV.isHidden = false
                            
                            for item in tempServices {
                                self.urls.append(item["image"].string!)
                            }
                            self.serviceImagesCV.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func addToCart(_ sender: Any) {
        tabBarController?.tabBar.items?[1].isEnabled = true
        tabBarController?.tabBar.items?[1].badgeValue = ""
        

        Cart.currentCart.bookingType = ShopViewController.BOOKING_TYPE_VAR
        let cartItem = CartItem(service: self.service!)
        
        guard let cartShop = Cart.currentCart.shop, let currentShop = self.shop else {
            setAddedToCartButton()
            Cart.currentCart.shop = self.shop
            Cart.currentCart.items.append(cartItem)
            return
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        if cartShop.id == currentShop.id && !checkServiceInCart() {
            setAddedToCartButton()
            Cart.currentCart.items.append(cartItem)
        } else { 
            let alertView = UIAlertController(
                title: "Clear Cart?",
                message: "You were booking from another shop. Would you like to clear current cart and start a new booking?",
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Start New Booking", style: .destructive) { (action: UIAlertAction!) in
                self.setAddedToCartButton()
                Cart.currentCart.items = []
                Cart.currentCart.items.append(cartItem)
                Cart.currentCart.shop = self.shop
            }
            
            alertView.addAction(okAction)
            alertView.addAction(cancelAction)
            
            self.present(alertView, animated: true, completion: nil)
        }
    }
}



extension ServiceDetailsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: collectionView.frame.height - 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return data.count
        
        return self.urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        let serviceDefault = UIImageView()
        let defaultImage = UIImage(named: "loading")
        serviceDefault.image = defaultImage

        cell.data = self.urls[indexPath.item]
        cell.backgroundView = serviceDefault
        cell.layer.cornerRadius = 12
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var image: UIImage?
        let urlString = self.urls[indexPath.item]

        let url = NSURL(string: urlString)! as URL
        if let imageData: NSData = NSData(contentsOf: url) {
            image = UIImage(data: imageData as Data)
        }
        
        let imageInfo = GSImageInfo(image: image!, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: collectionView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
      
        present(imageViewer, animated: true)
    }
}






