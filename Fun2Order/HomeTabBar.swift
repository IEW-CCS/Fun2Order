//
//  HomeTabBar.swift
//  Fun2Order
//
//  Created by chris on 2019/10/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class HomeTabBar : UITabBarController
{
    override func viewDidLoad() {
        super .viewDidLoad()
        navigationController?.viewControllers = [self]
        let app = UIApplication.shared.delegate as! AppDelegate
        app.myTabBar = self.tabBar
        setupTokenID()
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
    
    func setupTokenID() {
        if Auth.auth().currentUser?.uid != nil {
            print("Upload Token ID in HomeTabBar")
            let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
            if let plist = NSMutableDictionary(contentsOfFile: path) {
                if let tokenID = plist["FirebaseInstanceID"] as? String {
                    uploadUserProfileTokenID(user_id: Auth.auth().currentUser!.uid, token_id: tokenID)
                }
            }
        }
    }

}
