//
//  CustomImageView.swift
//  tribarb
//
//  Created by Anith Manu on 31/12/2020.
//

import UIKit
import SkeletonView

let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    var task: URLSessionDataTask!
    
    // Helper to load image asynchronously
    func loadImage(_ urlString: String) {
        
        imageUrlString = urlString
        
        let imgURL: URL = URL(string: urlString)!
        
        image = nil
        
        startLoadingShimmer()
        
        if let task = task {
            task.cancel()
        }
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            stopLoadingShimmer()
            return
        }
    
        task = URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
            
            guard
                let data = data,
                let newImage = UIImage(data: data)
            else {
                return
            }
            
            imageCache.setObject(newImage, forKey: urlString as AnyObject)
            
            DispatchQueue.main.async {
                if self.imageUrlString == urlString {
                    self.image = newImage
                }
                
                imageCache.setObject(newImage, forKey: urlString as AnyObject)
                self.stopLoadingShimmer()
            }

        }
        
        task.resume()
    }
    
    
    
    func startLoadingShimmer() {
        self.isSkeletonable = true
        self.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: UIColor(rgb: 0xEEEEEF)), animation: nil, transition: .crossDissolve(0.25))
    }
    
    
    func stopLoadingShimmer() {
        self.stopSkeletonAnimation()
        self.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
    }
}
