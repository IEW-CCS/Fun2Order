//
//  UIViewController+BackBtnEventIntercept.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/17.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit

/*
public protocol ShouldPopDelegate {
    func currentViewControllerShouldPop() -> Bool
}


@objc extension UIViewController: ShouldPopDelegate {
    public func currentViewControllerShouldPop() -> Bool {
        return true
    }
}

extension UINavigationController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        //print("CreateMenuTableViewController navigationBar shouldPop event processed!!!")
        var shouldPop = true
        let currentVC = self.topViewController
        
        if (currentVC?.responds(to: #selector(currentViewControllerShouldPop)))! {
            shouldPop = (currentVC?.currentViewControllerShouldPop())!
        }
        
        if shouldPop {
            DispatchQueue.main.async {
                self.popViewController(animated: true)
            }
            return true
        } else {
            for subView in navigationBar.subviews {
                if 0.0 < subView.alpha && subView.alpha < 1.0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        subView.alpha = 1.0
                    })
                }
            }
            return false
        }
    }
}
*/
