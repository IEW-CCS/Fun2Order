//
//  FunctionsPageViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class FunctionsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{

    var functionViewControllers: [UIViewController] = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.functionViewControllers = [getViewController(identifier: "BASIC_INFO_VC"), getViewController(identifier: "CONFIG_FAVORITE_VC"), getViewController(identifier: "MEMBER_GROUP_VC")]
        
        dataSource = self
        delegate = self
        
        if let firstViewController = self.functionViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
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
                NotificationCenter.default.post(name: NSNotification.Name("PageChange"), object: index)
                //pageDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: index)
            }
    }
    
}

