//
//  ViewController.swift
//  tribarb
//
//  Created by Anith Manu on 18/10/2020.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

}



import Foundation


class CustomTextField:UITextField{

    override init(frame: CGRect) {
        super.init(frame: frame)
        setProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProperties()
    }

    func setProperties(){

        backgroundColor = UIColor.white
        textAlignment = .left
        textColor = .black
        font = UIFont.systemFont(ofSize: 15)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 5 
        if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
    }
}
