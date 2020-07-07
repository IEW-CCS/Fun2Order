//
//  NotificationTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class NotificationTableViewController: UITableViewController {
    @IBOutlet weak var segmentType: UISegmentedControl!
    
    var notificationList: [NotificationData] = [NotificationData]()
    var typeNotificationList: [NotificationData] = [NotificationData]()
    var adBannerView: GADBannerView!
    var isAdLoadedSuccess: Bool = false
    var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        app.notificationDelegate = self
        
        let notificationCellViewNib: UINib = UINib(nibName: "NotificationActionCell", bundle: nil)
        self.tableView.register(notificationCellViewNib, forCellReuseIdentifier: "NotificationActionCell")
        
        let adCellViewNib: UINib = UINib(nibName: "BannerAdCell", bundle: nil)
        self.tableView.register(adCellViewNib, forCellReuseIdentifier: "BannerAdCell")

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "正在更新通知列表")
        self.tableView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)

        self.segmentType.selectedSegmentIndex = 0
        self.notificationList = retrieveNotificationList()
        filterNotificationTypeList(index: self.selectedIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "通知列表"
        self.navigationController?.title = "通知列表"
        self.tabBarController?.title = "通知列表"
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
        setupBannerAdView()
    }

    func setupBannerAdView() {
        self.adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        
        // iOS-NotificationList-BannerAd adUnitID
        //self.adBannerView.adUnitID = "ca-app-pub-6672968234138119/9417830726"
        self.adBannerView.adUnitID = NOTIFICATIONLIST_BANNER_AD
        self.adBannerView.delegate = self
        self.adBannerView.rootViewController = self
        self.adBannerView.load(GADRequest())
    }

    func filterNotificationTypeList(index: Int) {
        self.typeNotificationList.removeAll()
        
        if self.notificationList.isEmpty {
            return
        }
        
        for i in 0...self.notificationList.count - 1 {
            switch index {
                case 0:
                    if self.notificationList[i].notificationType == NOTIFICATION_TYPE_ACTION_JOIN_ORDER {
                        self.typeNotificationList.append(self.notificationList[i])
                    }
                    break
                case 1:
                    if self.notificationList[i].notificationType == NOTIFICATION_TYPE_SHIPPING_NOTICE {
                        self.typeNotificationList.append(self.notificationList[i])
                    }
                    break
                default:
                    if self.notificationList[i].notificationType != NOTIFICATION_TYPE_ACTION_JOIN_ORDER && self.notificationList[i].notificationType != NOTIFICATION_TYPE_SHIPPING_NOTICE {
                        self.typeNotificationList.append(self.notificationList[i])
                    }
                    break
            }
        }
    }
    
    @objc func refreshList() {
        self.notificationList.removeAll()
        self.notificationList = retrieveNotificationList()
        self.filterNotificationTypeList(index: self.selectedIndex)
        DispatchQueue.main.async {
            setNotificationBadgeNumber()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        setupBannerAdView()
    }
    
    @IBAction func changeNotificationListType(_ sender: UISegmentedControl) {
        self.selectedIndex = sender.selectedSegmentIndex
        self.filterNotificationTypeList(index: self.selectedIndex)
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            //if self.notificationList.isEmpty {
            //    return 0
            //}
            
            //return self.notificationList.count
            if self.typeNotificationList.isEmpty {
                return 0
            }
            
            return self.typeNotificationList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if !self.isAdLoadedSuccess {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerAdCell", for: indexPath) as! BannerAdCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let adSize = GADAdSizeFromCGSize(CGSize(width: CGFloat(self.tableView.contentSize.width - 20), height: CGFloat(NOTIFICATION_LIST_BANNER_AD_HEIGHT - 20)))
            self.adBannerView.adSize = adSize
            cell.contentView.addSubview(self.adBannerView)
            self.adBannerView.center = cell.contentView.center

            cell.AdjustAutoLayout()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationActionCell", for: indexPath) as! NotificationActionCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.AdjustAutoLayout()
            //cell.setData(notification: self.notificationList[indexPath.row])
            cell.setData(notification: self.typeNotificationList[indexPath.row])
            
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if self.isAdLoadedSuccess {
                //print("section 0 height return\(NOTIFICATION_LIST_BANNER_AD_HEIGHT)")
                return CGFloat(NOTIFICATION_LIST_BANNER_AD_HEIGHT)
            } else {
                //print("section 0 height return 0")
                return 0
            }
        } else {
            return 90
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.typeNotificationList[indexPath.row].notificationType {
            case NOTIFICATION_TYPE_MESSAGE_DUETIME, NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let notifyActionController = storyBoard.instantiateViewController(withIdentifier: "NOTIFY_ACTION_VC") as? NotificationActionTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: NOTIFY_ACTION_VC can't find!! (NotificationTableViewController)")
                    return
                }
                notifyActionController.notificationData = self.typeNotificationList[indexPath.row]
                notifyActionController.indexPath = indexPath
                self.typeNotificationList[indexPath.row].isRead = "Y"
                updateNotificationReadStatus(message_id: self.typeNotificationList[indexPath.row].messageID, status: true)
                setNotificationBadgeNumber()

                guard let cell = self.tableView.cellForRow(at: indexPath) as? NotificationActionCell else {
                    return
                }
                cell.setData(notification: self.typeNotificationList[indexPath.row])
                
                navigationController?.show(notifyActionController, sender: self)

                break
                
            case NOTIFICATION_TYPE_MESSAGE_INFORMATION:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let notifyInfoController = storyBoard.instantiateViewController(withIdentifier: "NOTIFY_MESSAGE_VC") as? NotificationMessageTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: NOTIFY_INFO_VC can't find!! (NotificationTableViewController)")
                    return
                }
                notifyInfoController.notificationData = self.typeNotificationList[indexPath.row]
                //notifyInfoController.indexPath = indexPath
                self.typeNotificationList[indexPath.row].isRead = "Y"
                updateNotificationReadStatus(message_id: self.typeNotificationList[indexPath.row].messageID, status: true)
                setNotificationBadgeNumber()
                guard let cell = self.tableView.cellForRow(at: indexPath) as? NotificationActionCell else {
                    return
                }
                cell.setData(notification: self.typeNotificationList[indexPath.row])

                navigationController?.show(notifyInfoController, sender: self)

                break
            case NOTIFICATION_TYPE_SHIPPING_NOTICE:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let notifyInfoController = storyBoard.instantiateViewController(withIdentifier: "SHIPPING_NOTICE_DETAIL_VC") as? ShippingNoticeDetailTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: SHIPPING_NOTICE_DETAIL_VC can't find!! (NotificationTableViewController)")
                    return
                }
                notifyInfoController.notificationData = self.typeNotificationList[indexPath.row]
                self.typeNotificationList[indexPath.row].isRead = "Y"
                updateNotificationReadStatus(message_id: self.typeNotificationList[indexPath.row].messageID, status: true)
                setNotificationBadgeNumber()
                guard let cell = self.tableView.cellForRow(at: indexPath) as? NotificationActionCell else {
                    return
                }
                cell.setData(notification: self.typeNotificationList[indexPath.row])

                navigationController?.show(notifyInfoController, sender: self)
                break

            default:
                break
        }



/*
        switch self.notificationList[indexPath.row].notificationType {
            case NOTIFICATION_TYPE_MESSAGE_DUETIME, NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let notifyActionController = storyBoard.instantiateViewController(withIdentifier: "NOTIFY_ACTION_VC") as? NotificationActionTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: NOTIFY_ACTION_VC can't find!! (NotificationTableViewController)")
                    return
                }
                notifyActionController.notificationData = self.notificationList[indexPath.row]
                notifyActionController.indexPath = indexPath
                self.notificationList[indexPath.row].isRead = "Y"
                updateNotificationReadStatus(message_id: self.notificationList[indexPath.row].messageID, status: true)
                setNotificationBadgeNumber()

                guard let cell = self.tableView.cellForRow(at: indexPath) as? NotificationActionCell else {
                    return
                }
                cell.setData(notification: self.notificationList[indexPath.row])
                
                navigationController?.show(notifyActionController, sender: self)

                break
                
            case NOTIFICATION_TYPE_MESSAGE_INFORMATION:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let notifyInfoController = storyBoard.instantiateViewController(withIdentifier: "NOTIFY_MESSAGE_VC") as? NotificationMessageTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: NOTIFY_INFO_VC can't find!! (NotificationTableViewController)")
                    return
                }
                notifyInfoController.notificationData = self.notificationList[indexPath.row]
                //notifyInfoController.indexPath = indexPath
                self.notificationList[indexPath.row].isRead = "Y"
                updateNotificationReadStatus(message_id: self.notificationList[indexPath.row].messageID, status: true)
                setNotificationBadgeNumber()
                guard let cell = self.tableView.cellForRow(at: indexPath) as? NotificationActionCell else {
                    return
                }
                cell.setData(notification: self.notificationList[indexPath.row])

                navigationController?.show(notifyInfoController, sender: self)

                break
            case NOTIFICATION_TYPE_SHIPPING_NOTICE:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let notifyInfoController = storyBoard.instantiateViewController(withIdentifier: "SHIPPING_NOTICE_DETAIL_VC") as? ShippingNoticeDetailTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: SHIPPING_NOTICE_DETAIL_VC can't find!! (NotificationTableViewController)")
                    return
                }
                notifyInfoController.notificationData = self.notificationList[indexPath.row]
                self.notificationList[indexPath.row].isRead = "Y"
                updateNotificationReadStatus(message_id: self.notificationList[indexPath.row].messageID, status: true)
                setNotificationBadgeNumber()
                guard let cell = self.tableView.cellForRow(at: indexPath) as? NotificationActionCell else {
                    return
                }
                cell.setData(notification: self.notificationList[indexPath.row])

                navigationController?.show(notifyInfoController, sender: self)
                break

            default:
                break
        }
*/
    }

/*
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "刪除") { (action, indexPath) in

        }

        return [delete]
    }
*/

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除通知", message: "確定要刪除此通知嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this notification")
                //deleteNotificationByID(message_id: self.notificationList[indexPath.row].messageID)
                deleteNotificationByID(message_id: self.typeNotificationList[indexPath.row].messageID)
                alertWindow.isHidden = true
                self.notificationList = retrieveNotificationList()
                self.filterNotificationTypeList(index: self.selectedIndex)
                setNotificationBadgeNumber()
                self.tableView.reloadData()
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to delete the notification")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            //app.window?.rootViewController!.present(controller, animated: true, completion: nil)
            alertWindow = presentAlert(controller)
        }
    }

}

extension NotificationTableViewController: ApplicationRefreshNotificationDelegate {
    func refreshNotificationList() {
        print("NotificationTableViewController received ApplicationRefreshNotificationDelegate refreshNotificationList")
        self.notificationList.removeAll()
        self.notificationList = retrieveNotificationList()
        DispatchQueue.main.async {
            setNotificationBadgeNumber()
            self.tableView.reloadData()
        }
    }
}

extension NotificationTableViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        self.isAdLoadedSuccess = true
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
        self.isAdLoadedSuccess = false
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        //self.tableView.reloadData()
    }
}
