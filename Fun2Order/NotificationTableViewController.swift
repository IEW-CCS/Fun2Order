//
//  NotificationTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {
    var notificationList: [NotificationData] = [NotificationData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        app.notificationDelegate = self
        
        let notificationCellViewNib: UINib = UINib(nibName: "NotificationActionCell", bundle: nil)
        self.tableView.register(notificationCellViewNib, forCellReuseIdentifier: "NotificationActionCell")
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "正在更新通知列表")
        self.tableView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)

        self.notificationList = retrieveNotificationList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "通知列表"
        self.navigationController?.title = "通知列表"
        self.tabBarController?.title = "通知列表"
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
        
    }

    @objc func refreshList() {
        self.notificationList.removeAll()
        self.notificationList = retrieveNotificationList()
        DispatchQueue.main.async {
            setNotificationBadgeNumber()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.notificationList.isEmpty {
            return 0
        }
        
        return self.notificationList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationActionCell", for: indexPath) as! NotificationActionCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.AdjustAutoLayout()
        cell.setData(notification: self.notificationList[indexPath.row])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.notificationList[indexPath.row].notificationType {
            case NOTIFICATION_TYPE_MESSAGE_DUETIME, NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let notifyActionController = storyBoard.instantiateViewController(withIdentifier: "NOTIFY_ACTION_VC") as? NotificationActionViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: NOTIFY_ACTION_VC can't find!! (QRCodeViewController)")
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
                    assertionFailure("[AssertionFailure] StoryBoard: NOTIFY_INFO_VC can't find!! (QRCodeViewController)")
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

                notifyInfoController.notificationData = self.notificationList[indexPath.row]
                navigationController?.show(notifyInfoController, sender: self)

                break
                
            default:
                break
        }
    }

/*
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "刪除") { (action, indexPath) in

        }

        return [delete]
    }
*/

/*
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("NotificationTableViewController -> trailingSwipeActionsConfigurationForRowAt")
    }
*/
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除通知", message: "確定要刪除此通知嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this notification")
                deleteNotificationByID(message_id: self.notificationList[indexPath.row].messageID)
                alertWindow.isHidden = true
                self.notificationList = retrieveNotificationList()
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
