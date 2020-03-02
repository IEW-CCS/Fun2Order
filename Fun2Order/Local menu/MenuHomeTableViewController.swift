//
//  MenuHomeTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMobileAds

class MenuHomeTableViewController: UITableViewController {
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var adBannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("sqlite path --> \(app.persistentContainer.persistentStoreDescriptions)")

        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")

        let adCellViewNib: UINib = UINib(nibName: "MenuHomeNativeAdCell", bundle: nil)
        self.tableView.register(adCellViewNib, forCellReuseIdentifier: "MenuHomeNativeAdCell")

        setNotificationBadgeNumber()
        setupBannerAdView()
    }

    func setupBannerAdView() {
        self.adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        
        // MenuHomeBannerAd adUnitID
        //adBannerView.adUnitID = "ca-app-pub-9511677579097261/2511330037"
        //Google Test adUnitID
        self.adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.adBannerView.delegate = self
        self.adBannerView.rootViewController = self
        self.adBannerView.load(GADRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
        self.title = "菜單首頁"
        self.navigationController?.title = "菜單首頁"
        self.tabBarController?.title = "菜單首頁"
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuHomeNativeAdCell", for: indexPath) as! MenuHomeNativeAdCell
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                let adSize = GADAdSizeFromCGSize(CGSize(width: CGFloat(self.tableView.contentSize.width), height: CGFloat(MENU_HOME_BANNER_AD_HEIGHT)))
                self.adBannerView.adSize = adSize
                cell.contentView.addSubview(self.adBannerView)
                self.adBannerView.center = cell.contentView.center
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
               
                let iconImage: UIImage = UIImage(named: "Icon_Menu_List.png")!.withRenderingMode(.alwaysTemplate)
                cell.setData(icon: iconImage, button_text: "菜單列表", action_type: BUTTON_ACTION_MENU_LIST)

                cell.delegate = self
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }
            
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
               
                let iconImage: UIImage = UIImage(named: "Icon_Menu_Item.png")!.withRenderingMode(.alwaysTemplate)
                cell.setData(icon: iconImage, button_text: "製作菜單", action_type: BUTTON_ACTION_MENU_CREATE)

                cell.delegate = self
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }

            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
               
                let iconImage: UIImage = UIImage(named: "Icon_About.png")!.withRenderingMode(.alwaysTemplate)
                cell.setData(icon: iconImage, button_text: "關於我們", action_type: BUTTON_ACTION_ABOUT)

                cell.delegate = self
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }
        }
        
        let cell = UITableViewCell()
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat(MENU_HOME_BANNER_AD_HEIGHT)
        } else {
            return 54
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont.systemFont(ofSize: 24)
            header.textLabel?.text = "Fun2Order主要功能"
            header.textLabel?.textAlignment = .center
            header.textLabel?.textColor = UIColor.systemBlue
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 60
    }

}

extension MenuHomeTableViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
    }
     
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}

extension MenuHomeTableViewController: BasicButtonDelegate {
    func menuList(sender: BasicButtonCell) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let menuListController = storyBoard.instantiateViewController(withIdentifier: "MENULIST_VC") as? MenuListTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: MENULIST_VC can't find!! (QRCodeViewController)")
            return
        }
        navigationController?.show(menuListController, sender: self)
    }
    
    func menuCreate(sender: BasicButtonCell) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let menuCreateController = storyBoard.instantiateViewController(withIdentifier: "CREATEMENU_VC") as? CreateMenuTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: CREATEMENU_VC can't find!! (QRCodeViewController)")
            return
        }
        
        navigationController?.show(menuCreateController, sender: self)
    }
    
    func displayAbout(sender: BasicButtonCell) {
        //testFirebaseJSONUpload()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Banner_VC") as? BannerDetailViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: Banner_VC can't find!! (ViewController)")
            return
        }

        let img = UIImage(named: "Fun2Order_AppStore_Icon.png")!
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let buildString = "Version: \(appVersion ?? "").\(build ?? "")"
        
        let aboutDescription = "歡迎使用Fun2Order\n\n\(buildString)\n\nTeamPlus@JStudio\n@2019-2020 Copyrignt Reserved"
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc, animated: true, completion: nil)
        vc.setData(image_name: img, image_description: aboutDescription)
    }
}
