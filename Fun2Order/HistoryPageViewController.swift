//
//  HistoryPageViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class HistoryPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{

    var functionViewControllers: [UIViewController] = [UIViewController]()
    var menuOrder: MenuOrder = MenuOrder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.functionViewControllers = [getViewController(identifier: "STATUS_SUMMARY_VC"), getViewController(identifier: "ORDER_SUMMARY_VC"), getViewController(identifier: "PAYMENT_SUMMARY_VC")]
        
        dataSource = self
        delegate = self
        
        prepareData()
        
        if let firstViewController = self.functionViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveHistoryPageIndexChange(_:)),
            name: NSNotification.Name(rawValue: "HistoryPageIndexChange"),
            object: nil
        )
    }
    
    func prepareData() {
        for i in 0...self.functionViewControllers.count - 1 {
            switch i {
            case 0:
                let controller = self.functionViewControllers[0] as? StatusSummaryTableViewController
                controller?.menuOrder = self.menuOrder
                
            case 1:
                let controller = self.functionViewControllers[1] as? OrderItemSummaryTableViewController
                controller?.menuOrder = self.menuOrder

            case 2:
                let controller = self.functionViewControllers[2] as? EditPaymentStatusTableViewController
                controller?.menuOrder = self.menuOrder

            default:
                break
            }
        }
    }
    
    @objc func receiveHistoryPageIndexChange(_ notification: Notification) {
        if let pageIndex = notification.object as? Int {
            print("HistoryPageViewController received IndexChange notification for index[\(pageIndex)]")
            self.setViewControllers([self.functionViewControllers[pageIndex]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func getViewController(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.functionViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        var lastIndex: Int = 0
        
        if viewControllerIndex == 0 {
            lastIndex = self.functionViewControllers.count - 1
        } else {
            lastIndex = viewControllerIndex - 1
        }
        return self.functionViewControllers[lastIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.functionViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        var afterIndex: Int = 0
        
        if viewControllerIndex == self.functionViewControllers.count - 1 {
            afterIndex = 0
        } else {
            afterIndex = viewControllerIndex + 1
        }
        return self.functionViewControllers[afterIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = functionViewControllers.firstIndex(of: firstViewController) {
                NotificationCenter.default.post(name: NSNotification.Name("HistoryPageChange"), object: index)
            }
    }
}
