//
//  MyProfileViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/12.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    @IBOutlet weak var imageMyPhoto: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    var segmentIndicator = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegment()
        self.imageMyPhoto.layer.cornerRadius = 40
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "我的設定"
        self.navigationController?.title = "我的設定"
        self.tabBarController?.title = "我的設定"
    }
    
    override func viewDidLayoutSubviews() {
        print("**************  viewDidLayoutSubviews to setupSegmentIndicator")
        setupSegmentIndicator()
    }
    
    @IBAction func selectFunctions(_ sender: UISegmentedControl) {
        let numberOfSegments = CGFloat(self.segmentControl.numberOfSegments)
        let segmentWidth = CGFloat((self.segmentControl.layer.frame.maxX - self.segmentControl.layer.frame.minX)/numberOfSegments)

        print("Before self.segmentIndicator.constraints = \(self.segmentIndicator.constraints.count)")
        self.segmentIndicator.removeConstraints(self.segmentIndicator.constraints)
        print("After self.segmentIndicator.constraints = \(self.segmentIndicator.constraints.count)")

        self.segmentIndicator.topAnchor.constraint(equalTo: self.segmentControl.bottomAnchor, constant: 3).isActive = true
        self.segmentIndicator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        self.segmentIndicator.widthAnchor.constraint(equalToConstant: CGFloat(segmentWidth - 20)).isActive = true
        
        print("self.segmentControl.selectedSegmentIndex = \(self.segmentControl.selectedSegmentIndex)")
        self.segmentIndicator.centerXAnchor.constraint(equalTo: self.segmentControl.subviews[getSubViewIndex()].centerXAnchor).isActive = true

        self.segmentIndicator.updateConstraints()
        //UIView.animate(withDuration: 0.1, animations: {
        //    self.view.layoutIfNeeded()
        //})
    }
    
    func setupSegmentIndicator() {
        let numberOfSegments = CGFloat(self.segmentControl.numberOfSegments)
        let segmentWidth = CGFloat((self.segmentControl.layer.frame.maxX - self.segmentControl.layer.frame.minX)/numberOfSegments)

        //print("numberOfSegments = \(numberOfSegments)")
        //print("segmentWidth = \(segmentWidth)")

        self.segmentIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.segmentIndicator.backgroundColor = CUSTOM_COLOR_LIGHT_ORANGE
        self.view.addSubview(self.segmentIndicator)
        
        self.segmentIndicator.topAnchor.constraint(equalTo: self.segmentControl.bottomAnchor, constant: 3).isActive = true
        self.segmentIndicator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        self.segmentIndicator.widthAnchor.constraint(equalToConstant: CGFloat(segmentWidth - 20)).isActive = true
        
        print("self.segmentControl.selectedSegmentIndex = \(self.segmentControl.selectedSegmentIndex)")
        self.segmentIndicator.centerXAnchor.constraint(equalTo: self.segmentControl.subviews[getSubViewIndex()].centerXAnchor).isActive = true
    }
    
    func getSubViewIndex() -> Int {
        struct xIndex {
            var index: Int = 0
            var centerX = CGFloat(0.0)
        }

        var indexArray = [xIndex]()
        
        for i in 0...self.segmentControl.subviews.count - 1 {
            var tmp = xIndex()
            tmp.index = i
            tmp.centerX = self.segmentControl.subviews[i].center.x
            indexArray.append(tmp)
        }
        
        //print("indexArray Before sorting: \(indexArray)")
        
        let result = indexArray.sorted { $0.centerX < $1.centerX }
        //print("indexArray After sorting: \(result)")
        //print("-----------------------------------------")
        //print("self.segmentControl.selectedSegmentIndex = \(self.segmentControl.selectedSegmentIndex)")
        //print("getSubViewIndex return index = \(result[self.segmentControl.selectedSegmentIndex].index)")
        //print("result X value = \(result[self.segmentControl.selectedSegmentIndex].centerX)")
        //print("-----------------------------------------")
        return result[self.segmentControl.selectedSegmentIndex].index
    }
    
    func setupSegment() {
        self.segmentControl.backgroundColor = .clear
        self.segmentControl.tintColor = .clear
        //self.segmentControl.tintColor = CUSTOM_COLOR_LIGHT_ORANGE
        
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNextCondensed-Medium", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNextCondensed-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: CUSTOM_COLOR_LIGHT_ORANGE], for: .selected)
        
        self.segmentControl.selectedSegmentIndex = 0
    }

}
