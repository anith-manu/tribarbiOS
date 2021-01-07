//
//  Helpers.swift
//  tribarb
//
//  Created by Anith Manu on 26/10/2020.
//

import Foundation
import SwiftyJSON



class Helpers {
    
    // Helper to load image asynchronously
    static func loadImage(_ imageView: UIImageView,_ urlString: String) {
        
        let imgURL: URL = URL(string: urlString)!
        URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
            
            guard let data = data, error == nil else {return}
            
            DispatchQueue.main.async(execute: {
                imageView.contentMode = .scaleToFill
                imageView.image = UIImage(data: data)
            })
        }.resume()
    }
    
    
    // Helper to show activity indicator
    static func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView,_ view: UIView) {

        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = UIColor.black
    
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }
    
    
    // Helper to hide activity indicator
    static func hideActivityIndicator(_ activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
    }
    
    
    // Helper to show activity indicator
    static func showWhiteOutActivityIndicator(_ activityIndicator: UIActivityIndicatorView,_ view: UIView) {
    
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = UIColor.black
        activityIndicator.backgroundColor = .white
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }
    
}
