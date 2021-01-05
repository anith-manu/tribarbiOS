//
//  EmployeeAccountViewController.swift
//  tribarb
//
//  Created by Anith Manu on 18/11/2020.
//

import UIKit

class EmployeeAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btUpdate: CurvedButton!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var accountScroll: UIScrollView!
    
    let activityIndicator = UIActivityIndicatorView()
    
    private let imageView = CustomImageView()
    
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 20
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        accountScroll.keyboardDismissMode = .interactive
        
        
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneClicked))
        doneButton.tintColor = UIColor(red: 1.00, green: 0.76, blue: 0.43, alpha: 1.00)
        
        toolbar.setItems([doneButton], animated: false)
        
        tfPhone.inputAccessoryView = toolbar
        tfPhone.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    
    
    func disableUpdateButton() {
        self.btUpdate.isEnabled = false
        self.btUpdate.layer.opacity = 0.5
    }
    
    
    func enableUpdateButton() {
        self.btUpdate.isEnabled = true
        self.btUpdate.layer.opacity = 1
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        enableUpdateButton()
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        disableUpdateButton()
        
        if User.currentUser.shop == nil {
        
            Helpers.showWhiteOutActivityIndicator(activityIndicator, view)
            APIManager.shared.employeeGetDetails { (json) in
                if json != nil {
                    User.currentUser.setEmployeeInfo(json: json!)
                    self.setEmployeeInfo()
                }
                Helpers.hideActivityIndicator(self.activityIndicator)

            }
        } else {
            setEmployeeInfo()
        }
        
    }
    
    
    func setEmployeeInfo() {
        navigationItem.title = User.currentUser.name
        navigationItem.prompt = User.currentUser.shop
        
        if User.currentUser.pictureURL != nil {
            imageView.loadImage(User.currentUser.pictureURL!)
        }
        
    }
    

    @IBAction func updateInfo(_ sender: Any) {
        
        var phone = ""
        
        if tfPhone.hasText {
            phone = tfPhone.text!
        } else {
            phone = User.currentUser.phone!
        }
        
        
        if phone != User.currentUser.phone! {
            APIManager.shared.employeeUpdateDetails(phone: phone) { (json) in
                User.currentUser.phone = phone
                self.viewWillAppear(true)
                self.updateCompleteMessage()
            }
        }
    }
    
    
    @IBAction func logout(_ sender: Any) {
        let alertView = UIAlertController(
            title: "Logging Out",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction!) in
            
            FBManager.shared.logOut()
            User.currentUser.resetEmployeeInfo()
            APIManager.shared.logout { (error) in
                if error != nil {
                    print("Error while logging out.")
                }
            }
            
            self.performSegue(withIdentifier: "EmployeeLogout", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .default)
        
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    

    func updateCompleteMessage() {
        let message = "Updated Successfully"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        self.present(alert, animated: true)

        // duration in seconds
        let duration: Double = 1

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }
    
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)

        imageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
    }

}
