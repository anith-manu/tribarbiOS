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
        loadService()
        loadAlbum()
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
        tabBarController?.tabBar.items?[1].badgeColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        Cart.currentCart.bookingType = ShopViewController.BOOKING_TYPE_VAR
        let cartItem = CartItem(service: self.service!)
        
        guard let cartShop = Cart.currentCart.shop, let currentShop = self.shop else {
            Cart.currentCart.shop = self.shop
            Cart.currentCart.items.append(cartItem)
            addedToCartMessage()
            return
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if cartShop.id == currentShop.id {
            let inCart = Cart.currentCart.items.firstIndex { (item) -> Bool in
                return item.service.id! == cartItem.service.id!
            }
            
            if inCart != nil {
                let alertView = UIAlertController(
                    title: "Service Already Added",
                    message: "Your cart already has this service.",
                    preferredStyle: .alert)
                alertView.addAction(cancelAction)
                self.present(alertView, animated: true, completion: nil)

            } else {
                Cart.currentCart.items.append(cartItem)
                addedToCartMessage()
            }
        } else { 
            let alertView = UIAlertController(
                title: "Clear Cart?",
                message: "You were booking from another shop. Would you like to clear current cart and start a new booking?",
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Start New Booking", style: .default) { (action: UIAlertAction!) in
                Cart.currentCart.items = []
                Cart.currentCart.items.append(cartItem)
                Cart.currentCart.shop = self.shop
            }
            
            alertView.addAction(okAction)
            alertView.addAction(cancelAction)
            
            self.present(alertView, animated: true, completion: nil)
        }
        
    }
    
    
    func addedToCartMessage() {
        let message = "Added to cart"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)

        // duration in seconds
        let duration: Double = 1

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
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



class CustomCell: UICollectionViewCell {
    
    var data: String? {
        didSet {
            guard let data = data else { return }

            Helpers.loadImage(bg, data)
        }
    }
    
    
    fileprivate let bg: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(bg)
        bg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bg.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bg.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


