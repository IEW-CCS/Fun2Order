//
//  CartTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class CartTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let cartGroupCellViewNib: UINib = UINib(nibName: "CartGroupCell", bundle: nil)
        self.tableView.register(cartGroupCellViewNib, forCellReuseIdentifier: "CartGroupCell")

        let payCellViewNib: UINib = UINib(nibName: "PayCell", bundle: nil)
        self.tableView.register(payCellViewNib, forCellReuseIdentifier: "PayCell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.payByApplePay(_:)),
            name: NSNotification.Name(rawValue: "PayByApplePay"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.payByGooglePay(_:)),
            name: NSNotification.Name(rawValue: "PayByGooglePay"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.payByLinePay(_:)),
            name: NSNotification.Name(rawValue: "PayByLinePay"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.payByCash(_:)),
            name: NSNotification.Name(rawValue: "PayByCash"),
            object: nil
        )

    }
    
    @objc func payByApplePay(_ notification: Notification) {
        let alertController = UIAlertController(title: "Pay", message: "Pay by ApplePay", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated : false, completion : nil)
    }

    @objc func payByGooglePay(_ notification: Notification) {
        let alertController = UIAlertController(title: "Pay", message: "Pay by GooglePay", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated : false, completion : nil)
    }

    @objc func payByLinePay(_ notification: Notification) {
        let alertController = UIAlertController(title: "Pay", message: "Pay by LinePay", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated : false, completion : nil)
    }

    @objc func payByCash(_ notification: Notification) {
        let alertController = UIAlertController(title: "Pay", message: "Pay by Cash", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated : false, completion : nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartGroupCell", for: indexPath) as! CartGroupCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayCell", for: indexPath) as! PayCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 360
        }
        
        return 120
    }
}
