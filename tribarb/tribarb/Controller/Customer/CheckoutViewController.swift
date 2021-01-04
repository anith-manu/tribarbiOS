//
//  CheckoutViewController.swift
//  tribarb
//
//  Created by Anith Manu on 09/11/2020.
//

import UIKit

class CheckoutViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var checkoutScroll: UIScrollView!
    @IBOutlet weak var checkoutStackView: UIStackView!
    
    @IBOutlet weak var bookingPlacedBackground: UIView!
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var tbvServices: UITableView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var lbServiceFee: UILabel!
    @IBOutlet weak var lbSubTotal: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var bookingDate: UIDatePicker!
    @IBOutlet weak var tfRequest: UITextField!
    @IBOutlet weak var btNext: UIButton!
    
    @IBOutlet weak var bookingPlacedView: UIView!
    @IBOutlet weak var emptyCartView: UIView!
    @IBOutlet weak var lbShopNameBooked: UILabel!
    
    var fromController: Int = 0
    var shopName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(UIView())
        
        navigationController?.view.backgroundColor = UIColor.white

        self.bookingDate.minimumDate = Date()
        
        checkoutScroll.keyboardDismissMode = .interactive
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
          
            if tabBarController?.tabBar.bounds.height != nil {
                self.checkoutScroll.contentSize = CGSize(width: self.view.frame.width, height: self.checkoutStackView.frame.height+keyboardHeight-(tabBarController?.tabBar.bounds.height)!)
            }
        }
         
    }
    
    
    @objc func keyboardDisappear(_ notification: Notification) {
        self.checkoutScroll.contentSize = CGSize(width: self.view.frame.width, height: self.checkoutStackView.frame.height)
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
    
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.setHidesBackButton(true, animated: false)
    
        
        self.tbvServices.reloadData()
        
        if Cart.currentCart.items.isEmpty {
            tabBarController?.tabBar.items?[1].badgeValue = nil
            tabBarController?.tabBar.items?[1].isEnabled = false
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.shopView.isHidden = true
            self.totalView.isHidden = true
            self.tbvServices.isHidden = true

            if fromController ==  1 {
                self.lbShopNameBooked.text = "\(shopName!)."
                self.bookingPlacedView.isHidden = false
                self.emptyCartView.isHidden = true
                self.tabBarController?.tabBar.items?[2].badgeValue = ""

            } else {
                self.bookingPlacedView.isHidden = true
                self.emptyCartView.isHidden = false
            }
            
            fromController = 0
            
        } else {
            self.shopView.isHidden = false
            self.totalView.isHidden = false
            self.tbvServices.isHidden = false
            self.bookingPlacedView.isHidden = true
            self.emptyCartView.isHidden = true
            setDetails()
            
        }
    }
    
    

    
    
    func setDetails() {
        navigationItem.title = Cart.currentCart.shop?.name
        
        if Cart.currentCart.bookingType == 0 {
            navigationItem.prompt = "Shop Booking"
            navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "Shop Booking", style: .plain, target: nil, action: nil)
            self.btNext.setTitle("Payment", for: .normal)
        } else {
            navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "Home Booking", style: .plain, target: nil, action: nil)
            navigationItem.prompt = "Home Booking"
            self.btNext.setTitle("Address", for: .normal)
        }
        self.lbServiceFee.text = "£\(Cart.currentCart.getServiceFee())"
        self.lbSubTotal.text = "£\(Cart.currentCart.getSubtotal())"
        self.lbTotal.text = "£\(Cart.currentCart.getTotal())"
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    @objc func keyboardWillChange(notification: Notification) {

        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
    
            checkoutScroll.frame.origin.y = -keyboardRect.height+(tabBarController?.tabBar.bounds.height)!
        } else {
            checkoutScroll.frame.origin.y = 0
        }
    }
    
    
    @IBAction func next(_ sender: Any) {
        let dateFormatr = DateFormatter()
        //YYYY-MM-DD HH:MM
        dateFormatr.dateFormat = "YYYY-MM-dd HH:mm"
        let strDate = dateFormatr.string(from: (bookingDate?.date)!)
        
        Cart.currentCart.bookingTime = strDate
        Cart.currentCart.request = tfRequest.text
        
        if Cart.currentCart.bookingType == 0 {
            self.performSegue(withIdentifier: "Payment", sender: self)
        } else {
            self.performSegue(withIdentifier: "Address", sender: self)
        }
    }
    
    
    @IBAction func deleteRow(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tbvServices)
        guard let indexPath = tbvServices.indexPathForRow(at: point) else {
            return
        }
        Cart.currentCart.items.remove(at: indexPath.row)
        tbvServices.deleteRows(at: [indexPath], with: .left)
        
        viewWillAppear(true)
    }
}



extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cart.currentCart.items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutCell", for: indexPath) as! CheckoutTableViewCell
        let cart = Cart.currentCart.items[indexPath.row]
        cell.lbServiceName.text = cart.service.name
        cell.lbServicePrice.text = "£\(cart.service.price!)"
        cell.btnDelete.addTarget(self, action: #selector(deleteRow(_:)), for: .touchUpInside)
        return cell
    }
    
    
}
