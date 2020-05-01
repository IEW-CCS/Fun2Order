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
            
            let userDefaults = UserDefaults.standard
            if userDefaults.value(forKey: "appFirstTimeOpend") != nil {
                let firstRunFlag = userDefaults.value(forKey: "appFirstTimeOpend") as! Bool
                if firstRunFlag == true {
                    downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: reloadUserInfo)
                }
            }
        }
    }

    func reloadUserInfo(user_profile: UserProfile) {
        // For not first time using Fun2Order but first updated to version 0.9.14
        var profile = uploadLocalInformation(user_profile: user_profile)
        
        //let profile = user_profile
        
        if profile.friendList != nil {
            deleteAllFriends()
            for friend in profile.friendList! {
                var friendData: Friend = Friend()
                friendData.memberID = friend
                insertFriend(friend_info: friendData)
            }
        }
 
        if profile.brandCategoryList != nil {
            deleteAllMenuBrandCategory()
            for brand in profile.brandCategoryList! {
                insertMenuBrandCategory(category: brand)
            }
        }

        let userDefaults = UserDefaults.standard
        userDefaults.setValue(false, forKey: "appFirstTimeOpend")
    }
    
    func uploadLocalInformation(user_profile: UserProfile) -> UserProfile {
        var profile = user_profile
        var isUploadNeeded: Bool = false
        
        let friendList = retrieveFriendList()
        let brandList = retrieveMenuBrandCategory()
        
        if !friendList.isEmpty && profile.friendList == nil {
            var tmpFriends: [String] = [String]()
            for friendData in friendList {
                tmpFriends.append(friendData.memberID)
            }
            profile.friendList = tmpFriends
            isUploadNeeded = true
        }
        
        if !brandList.isEmpty && profile.brandCategoryList == nil {
            var tmpBrands: [String] = [String]()
            for brandData in brandList {
                tmpBrands.append(brandData)
            }
            profile.brandCategoryList = tmpBrands
            isUploadNeeded = true
        }
        
        if isUploadNeeded {
            uploadFBUserProfile(user_profile: profile)
        }
        
        return profile
    }
}
