//
//  HomeTabBar.swift
//  Fun2Order
//
//  Created by chris on 2019/10/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit
class HomeTabBar : UITabBarController
{
    override func viewDidLoad() {
        super .viewDidLoad()
        navigationController?.viewControllers = [self]
        let app = UIApplication.shared.delegate as! AppDelegate
        app.myTabBar = self.tabBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "首頁"
        self.navigationController?.title = "首頁"
        self.tabBarController?.title = "首頁"
    }
}
