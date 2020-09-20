//
//  BrandTabBarController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/19.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class BrandTabBarController: UITabBarController {

    var detailBrandProfile: DetailBrandProfile = DetailBrandProfile()
    var brandName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("BrandTabBarController viewControllers count = \(String(describing: self.viewControllers?.count))")
        downloadFBDetailBrandProfile(brand_name: self.brandName, completion: receiveFBDetailBrandProfile)
    }

    func receiveFBDetailBrandProfile(brand_profile: DetailBrandProfile?) {
        var backgroundColor: UIColor?
        var tabBarColor: UIColor?
        var textTintColor: UIColor?
        
        if brand_profile == nil {
            return
        }
        
        //testUpdateBrandProfile(brand_profile: brand_profile)
        //return

        self.detailBrandProfile = brand_profile!
        if self.detailBrandProfile.brandStyle != nil {
            if self.detailBrandProfile.brandStyle!.backgroundColor != nil {
                print("Get the background color definition!")
                print("self.detailBrandProfile.brandStyle!.backgroundColor! = \(self.detailBrandProfile.brandStyle!.backgroundColor!)")
                backgroundColor = UIColor(red: CGFloat(self.detailBrandProfile.brandStyle!.backgroundColor![0]/255), green: CGFloat(self.detailBrandProfile.brandStyle!.backgroundColor![1]/255), blue: CGFloat(self.detailBrandProfile.brandStyle!.backgroundColor![2]/255), alpha: 1.0)
                
                self.view.backgroundColor = backgroundColor
            }
            
            if self.detailBrandProfile.brandStyle!.tabBarColor != nil {
                print("Get the tab bar color definition!")
                print("self.detailBrandProfile.brandStyle!.tabBarColor! = \(self.detailBrandProfile.brandStyle!.tabBarColor!)")
                tabBarColor = UIColor(red: CGFloat(self.detailBrandProfile.brandStyle!.tabBarColor![0]/255), green: CGFloat(self.detailBrandProfile.brandStyle!.tabBarColor![1]/255), blue: CGFloat(self.detailBrandProfile.brandStyle!.tabBarColor![2]/255), alpha: 1.0)

                //self.tabBar.barTintColor = TEST_TABBAR_COLOR
                self.tabBar.barTintColor = tabBarColor
            }
            
            if self.detailBrandProfile.brandStyle!.tabBarColor != nil {
                print("Get the tab bar color definition!")
                print("self.detailBrandProfile.brandStyle!.tabBarColor! = \(self.detailBrandProfile.brandStyle!.tabBarColor!)")
                textTintColor = UIColor(red: CGFloat(self.detailBrandProfile.brandStyle!.textTintColor![0]/255), green: CGFloat(self.detailBrandProfile.brandStyle!.textTintColor![1]/255), blue: CGFloat(self.detailBrandProfile.brandStyle!.textTintColor![2]/255), alpha: 1.0)

                self.tabBar.tintColor = textTintColor
            }
        }
        
        if self.viewControllers != nil {
            if !self.viewControllers!.isEmpty {
                let storyController = self.viewControllers![0] as! BrandStoryViewController
                if backgroundColor != nil {
                    storyController.brandBackgroundColor = backgroundColor
                }
                
                if textTintColor != nil {
                    storyController.brandTextTintColor = textTintColor
                }

                storyController.brandProfile = self.detailBrandProfile
                storyController.loadWebURL(url_string: self.detailBrandProfile.brandStoryURL)

                let eventController = self.viewControllers![1] as! BrandEventTableViewController
                if backgroundColor != nil {
                    eventController.brandBackgroundColor = backgroundColor
                }
                
                if textTintColor != nil {
                    eventController.brandTextTintColor = textTintColor
                }

                eventController.brandProfile = self.detailBrandProfile

                let menuController = self.viewControllers![2] as! BrandMenuTableViewController
                if backgroundColor != nil {
                    menuController.brandBackgroundColor = backgroundColor
                }
                
                if textTintColor != nil {
                    menuController.brandTextTintColor = textTintColor
                }

                menuController.brandProfile = self.detailBrandProfile

                let storeController = self.viewControllers![3] as! BrandStoreListTableViewController
                if backgroundColor != nil {
                    storeController.brandBackgroundColor = backgroundColor
                }
                
                if textTintColor != nil {
                    storeController.brandTextTintColor = textTintColor
                }

                storeController.brandProfile = self.detailBrandProfile
            }
        }
    }
}
