//
//  HistoryDetailViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var menuOrder: MenuOrder = MenuOrder()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegment()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveHistoryPageChange(_:)),
            name: NSNotification.Name(rawValue: "HistoryPageChange"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "訂單詳細資料"
        self.navigationController?.title = "訂單詳細資料"
        self.tabBarController?.title = "訂單詳細資料"
    }
    
    @IBAction func selectFunctions(_ sender: UISegmentedControl) {
        NotificationCenter.default.post(name: NSNotification.Name("HistoryPageIndexChange"), object: self.segmentControl.selectedSegmentIndex)
    }
    
    func setupSegment() {
        self.segmentControl.backgroundColor = .clear
        self.segmentControl.tintColor = .clear
        
        self.segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNextCondensed-Medium", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNextCondensed-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: CUSTOM_COLOR_LIGHT_ORANGE], for: .selected)
        
        self.segmentControl.selectedSegmentIndex = 0
    }
    
    @objc func receiveHistoryPageChange(_ notification: Notification) {
        if let pageIndex = notification.object as? Int {
            print("HistoryDetailViewController received HistoryPageChange notification for page[\(pageIndex)]")
            self.segmentControl.selectedSegmentIndex = pageIndex
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowHistoryPage" {
            if let pageController = segue.destination as? HistoryPageViewController {
                pageController.menuOrder = self.menuOrder
            }
        }
    }
}
