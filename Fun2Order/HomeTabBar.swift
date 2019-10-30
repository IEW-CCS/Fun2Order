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
        
    }
    
     override func viewWillAppear(_ animated: Bool) {
        
       
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
         navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
