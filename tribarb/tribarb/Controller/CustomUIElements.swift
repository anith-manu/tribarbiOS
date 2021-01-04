//
//  CustomUIElements.swift
//  tribarb
//
//  Created by Anith Manu on 20/12/2020.
//

import Foundation
import UIKit


final class CurvedButton : UIButton {

   override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
   }

   required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
   }

   private func setup() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
   }
}



final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}



final class ShadowView: UIView {

    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    
    func setupShadow() {
        self.layer.cornerRadius = 20
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 4
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.33
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}



final class CustomCell: UICollectionViewCell {
    
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



class PaymentViewElements : UIView {
    
    override var bounds: CGRect {
        didSet {
            setupBorder()
        }
    }
    func setupBorder() {
        self.layer.borderWidth = 0.3
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
    
    }
}


