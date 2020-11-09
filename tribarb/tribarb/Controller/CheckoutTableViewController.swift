//
//  CheckoutTableViewController.swift
//  tribarb
//
//  Created by Anith Manu on 20/10/2020.
//

import UIKit
import Stripe

class CheckoutTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var tbvCheckout: UITableView!
    @IBOutlet weak var viewBookingType: UIView!
    @IBOutlet weak var viewTotal: UIView!
    @IBOutlet weak var lbShopName: UILabel!
    @IBOutlet weak var lbBookingType: UILabel!
    @IBOutlet weak var tfRequest: UITextField!
    @IBOutlet weak var lbSubTotal: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var bookingDate: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewBookingType.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.00)
        self.bookingDate.preferredDatePickerStyle = .wheels
        self.bookingDate.minimumDate = Date()
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tbvCheckout.reloadData()
        if Cart.currentCart.items.isEmpty {
            tabBarController?.tabBar.items?[1].badgeValue = nil
            self.viewBookingType.isHidden = true
            self.viewTotal.isHidden = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
            navigationItem.leftBarButtonItem = backButton
            
        } else {
            self.navigationItem.title = "Cart"
            self.viewBookingType.isHidden = false
            self.viewTotal.isHidden = false
            setDetails()
        }
    }
    
    
    
    func setDetails() {
        self.lbShopName.text = Cart.currentCart.shop?.name
        if ShopViewController.BOOKING_TYPE_VAR == 0 {
            self.lbBookingType.text = "Shop Booking"
            self.btNext.setTitle("Add Payment", for: .normal)
        } else {
            self.lbBookingType.text = "Home Booking"
            self.btNext.setTitle("Add Address", for: .normal)
        }
        self.lbSubTotal.text = "£\(Cart.currentCart.getSubtotal())"
        self.lbTotal.text = "£\(Cart.currentCart.getTotal())"
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    @IBAction func next(_ sender: Any) {
        let dateFormatr = DateFormatter()
        //YYYY-MM-DD HH:MM
        dateFormatr.dateFormat = "YYYY-MM-dd HH:mm"
        let strDate = dateFormatr.string(from: (bookingDate?.date)!)
        
        Cart.currentCart.bookingTime = strDate
        Cart.currentCart.request = tfRequest.text
        
        if ShopViewController.BOOKING_TYPE_VAR == 0 {
            self.performSegue(withIdentifier: "Payment", sender: self)
        } else {
            self.performSegue(withIdentifier: "Address", sender: self)
        }
    }
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cart.currentCart.items.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete {
            Cart.currentCart.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            viewWillAppear(true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutCell", for: indexPath) as! CheckoutTableViewCell
        let cart = Cart.currentCart.items[indexPath.row]
        cell.lbServiceName.text = cart.service.name
        cell.lbServicePrice.text = "£\(cart.service.price!)"
        return cell
    }
    
}


