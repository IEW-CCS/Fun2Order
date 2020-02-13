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

class MenuHomeTableViewController: UITableViewController {
    let app = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("sqlite path --> \(app.persistentContainer.persistentStoreDescriptions)")

        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveMenuList(_:)),
            name: NSNotification.Name(rawValue: "MenuList"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveMenuCreate(_:)),
            name: NSNotification.Name(rawValue: "MenuCreate"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveDisplayAbout(_:)),
            name: NSNotification.Name(rawValue: "DisplayAbout"),
            object: nil
        )

        setNotificationBadgeNumber()
    }

    @objc func receiveMenuList(_ notification: Notification) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let menuListController = storyBoard.instantiateViewController(withIdentifier: "MENULIST_VC") as? MenuListTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: MENULIST_VC can't find!! (QRCodeViewController)")
            return
        }
        navigationController?.show(menuListController, sender: self)

    }
    
    @objc func receiveMenuCreate(_ notification: Notification) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let menuCreateController = storyBoard.instantiateViewController(withIdentifier: "CREATEMENU_VC") as? CreateMenuTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: CREATEMENU_VC can't find!! (QRCodeViewController)")
            return
        }
        navigationController?.show(menuCreateController, sender: self)
    }

    @objc func receiveDisplayAbout(_ notification: Notification) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Banner_VC") as? BannerDetailViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: Banner_VC can't find!! (ViewController)")
            return
        }

        let img = UIImage(named: "Fun2Order_AppStore_Icon.png")!
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let buildString = "Version: \(appVersion ?? "").\(build ?? "")"
        
        let aboutDescription = "歡迎使用Fun2Order\n\n\(buildString)\n\n@2019-2020 Copyrignt Reserved"
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc, animated: true, completion: nil)
        vc.setData(image_name: img, image_description: aboutDescription)
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
           
           let iconImage: UIImage = UIImage(named: "Icon_Menu_List.png")!
           cell.setData(icon: iconImage, button_text: "菜單列表", action_type: BUTTON_ACTION_MENU_LIST)

           cell.selectionStyle = UITableViewCell.SelectionStyle.none
           return cell
        }
        
        if indexPath.row == 2 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
           
           let iconImage: UIImage = UIImage(named: "Icon_Menu_Item.png")!
           cell.setData(icon: iconImage, button_text: "製作菜單", action_type: BUTTON_ACTION_MENU_CREATE)

           cell.selectionStyle = UITableViewCell.SelectionStyle.none
           return cell
        }

        if indexPath.row == 3 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
           
           let iconImage: UIImage = UIImage(named: "Icon_About.png")!
           cell.setData(icon: iconImage, button_text: "關於我們", action_type: BUTTON_ACTION_ABOUT)

           cell.selectionStyle = UITableViewCell.SelectionStyle.none
           return cell
        }

        let cell = UITableViewCell()
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 400
        }

        return 54
    }
    
}
