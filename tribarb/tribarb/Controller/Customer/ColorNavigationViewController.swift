//
//  ColorNavigationViewController.swift
//  tribarb
//
//  Created by Anith Manu on 30/12/2020.
//

import UIKit

class ColorNavigationViewController: UINavigationController {
    

    
    let orangeGradient = [UIColor(rgb: 0xFFC15D), UIColor(rgb: 0xFFC15D), UIColor(rgb: 0xFFC15D), UIColor(rgb: 0xffd590), UIColor(rgb: 0xffdeaa)]
    let orangeGradientLocation = [0.0, 0.25, 0.5, 0.85, 1.0]
    lazy var colorView = { () -> UIView in
    let view = UIView()
    view.isUserInteractionEnabled = false
    navigationBar.addSubview(view)
    navigationBar.sendSubviewToBack(view)
    return view
    }()
    
    
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
        configNavigationBar()
        changeGradientImage()
    }
    
    
    
    func configNavigationBar() {
        navigationBar.barStyle = .default
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
            
            
        let largeTitleAttrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "American Typewriter Semibold", size: 30) ??
                UIFont.systemFont(ofSize: 30)
        ]
        
        navigationBar.largeTitleTextAttributes = largeTitleAttrs
            
        
        let navBarAttrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "American Typewriter Semibold", size: 23) ??
            UIFont.systemFont(ofSize: 23)
        ]

        UINavigationBar.appearance().titleTextAttributes = navBarAttrs
        
    }
    
    
    func gradientImage(withColours colours: [UIColor], location: [Double], view: UIView) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = location as [NSNumber]
        gradient.cornerRadius = view.layer.cornerRadius
        return UIImage.image(from: gradient) ?? UIImage()
    }
    
    
    
    func changeGradientImage() {
        // 1 status bar
        colorView.frame = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: navigationBar.frame.width, height: UIApplication.shared.statusBarFrame.height)
        // 2
        colorView.backgroundColor = UIColor(patternImage: gradientImage(withColours: orangeGradient, location: orangeGradientLocation, view: navigationBar).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: navigationBar.frame.size.width/2, bottom: 10, right: navigationBar.frame.size.width/2), resizingMode: .stretch))
        // 3 small title background
        navigationBar.setBackgroundImage(gradientImage(withColours: orangeGradient, location: orangeGradientLocation, view: navigationBar), for: .default)
        // 4 large title background
        navigationBar.layer.backgroundColor = UIColor(patternImage: gradientImage(withColours: orangeGradient, location: orangeGradientLocation, view: navigationBar).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: navigationBar.frame.size.width/2, bottom: 10, right: navigationBar.frame.size.width/2), resizingMode: .stretch)).cgColor
    }

}



extension UIColor {
convenience init(red: Int, green: Int, blue: Int) {
assert(red >= 0 && red <= 255, "Invalid red component")
assert(green >= 0 && green <= 255, "Invalid green component")
assert(blue >= 0 && blue <= 255, "Invalid blue component")
self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
}
convenience init(rgb: Int) {
self.init(
red: (rgb >> 16) & 0xFF,
green: (rgb >> 8) & 0xFF,
blue: rgb & 0xFF
)
}
}
extension UIImage {
class func image(from layer: CALayer) -> UIImage? {
UIGraphicsBeginImageContextWithOptions(layer.bounds.size,
layer.isOpaque, UIScreen.main.scale)
defer { UIGraphicsEndImageContext() }
// Don't proceed unless we have context
guard let context = UIGraphicsGetCurrentContext() else {
return nil
}
layer.render(in: context)
return UIGraphicsGetImageFromCurrentImageContext()
}
}
