//
//  NotificationActionViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/2.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class NotificationActionViewController: UIViewController {
    @IBOutlet weak var labelOrderOwner: UILabel!
    @IBOutlet weak var labelReceiveTime: UILabel!
    @IBOutlet weak var labelDueTime: UILabel!
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var labelMemberCount: UILabel!
    @IBOutlet weak var labelNotificationType: UILabel!
    @IBOutlet weak var labelReplyStatus: UILabel!
    
    var notificationData: NotificationData = NotificationData()
    var indexPath: IndexPath = IndexPath()
    var interstitialAd: GADInterstitial!

    let app = UIApplication.shared.delegate as! AppDelegate
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationDelegate = app.notificationDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setData(notification: self.notificationData)
    }

    func setupInterstitialAd() {
        // Test Interstitla Video Ad
        self.interstitialAd = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/5135589807")

        // My real Interstitial Ad
        //self.interstitialAd = GADInterstitial(adUnitID: "ca-app-pub-9511677579097261/6069385370")

        let adRequest = GADRequest()
        self.interstitialAd.load(adRequest)
        self.interstitialAd.delegate = self

    }
    @IBAction func attendGroupOrder(_ sender: UIButton) {
        let dispatchGroup = DispatchGroup()
        var menuData: MenuInformation = MenuInformation()
        var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
        var memberIndex: Int = -1
        var user_id: String = ""
        var downloadMenuInformation: Bool = false
        var downloadMenuOrder: Bool = false

        if Auth.auth().currentUser?.uid != nil {
            user_id = Auth.auth().currentUser!.uid
        } else {
            print("Get Ahthorization uid failed")
            return
        }

        self.setupInterstitialAd()

        let databaseRef = Database.database().reference()
        
        let pathString = "USER_MENU_INFORMATION/\(self.notificationData.orderOwnerID)/\(self.notificationData.menuNumber)"
        
        dispatchGroup.enter()
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let menuInfo = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: menuInfo as Any, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)!
                print("jsonString = \(jsonString)")

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    menuData = try decoder.decode(MenuInformation.self, from: jsonData!)
                    downloadMenuInformation = true
                    print("menuData decoded successful !!")
                    print("menuData = \(menuData)")
                    dispatchGroup.leave()

                } catch {
                    dispatchGroup.leave()
                    print("attendGroupOrder menuData jsonData decode failed: \(error.localizedDescription)")
                }
            } else {
                dispatchGroup.leave()
                print("attendGroupOrder USER_MENU_INFORMATION snapshot doesn't exist!")
                return
            }
        }) { (error) in
            dispatchGroup.leave()
            print(error.localizedDescription)
        }

        let orderString = "USER_MENU_ORDER/\(self.notificationData.orderOwnerID)/\(self.notificationData.orderNumber)/contentItems"
        print("orderStirng = \(orderString)")
        dispatchGroup.enter()
        databaseRef.child(orderString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let itemRawData = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let itemArray = try decoder.decode([MenuOrderMemberContent].self, from: jsonData!)

                    if let itemIndex = itemArray.firstIndex(where: { $0.memberID == user_id }) {
                        //let uploadPathString = pathString + "/\(itemIndex)"
                        //databaseRef.child(uploadPathString).setValue(item.toAnyObject())
                        memberContent = itemArray[itemIndex]
                        memberIndex = itemIndex
                        downloadMenuOrder = true
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                } catch {
                    print("attendGroupOrder MenuOrderMemberContent jsonData decode failed: \(error.localizedDescription)")
                    dispatchGroup.leave()
                }
            } else {
                print("attendGroupOrder MenuOrderMemberContent snapshot doesn't exist!")
                dispatchGroup.leave()
            }
        }) { (error) in
            print(error.localizedDescription)
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if downloadMenuInformation == true && downloadMenuOrder == true && memberIndex >= 0 {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let joinController = storyBoard.instantiateViewController(withIdentifier: "JOIN_ORDER_VC") as? JoinGroupOrderTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (NotificationActionViewController)")
                    return
                }
                
                joinController.menuInformation = menuData
                joinController.memberContent = memberContent
                joinController.memberIndex = memberIndex
                //joinController.delegate = self
                self.navigationController?.show(joinController, sender: self)
            }

        }
    }
    
    @IBAction func notAttendGroupOrder(_ sender: UIButton) {
        let databaseRef = Database.database().reference()
        let pathString = "USER_MENU_ORDER/\(self.notificationData.orderOwnerID)/\(self.notificationData.orderNumber)/contentItems"
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let itemRawData = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    var itemArray = try decoder.decode([MenuOrderMemberContent].self, from: jsonData!)

                    if let user_id = Auth.auth().currentUser?.uid {
                        if let itemIndex = itemArray.firstIndex(where: { $0.memberID == user_id }) {
                            let uploadPathString = pathString + "/\(itemIndex)"

                            itemArray[itemIndex].orderContent.replyStatus = MENU_ORDER_REPLY_STATUS_REJECT
                            databaseRef.child(uploadPathString).setValue(itemArray[itemIndex].toAnyObject())
                        }
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = DATETIME_FORMATTER
                    let dateString = formatter.string(from: Date())
                    updateNotificationReplyStatus(order_number: self.notificationData.orderNumber, reply_status: MENU_ORDER_REPLY_STATUS_REJECT, reply_time: dateString)
                    self.refreshNotificationDelegate?.refreshNotificationList()

                } catch {
                    print("notAttendGroupOrder jsonData decode failed: \(error.localizedDescription)")
                }
            } else {
                print("notAttendGroupOrder snapshot doesn't exist!")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    func setData(notification: NotificationData) {
        self.labelOrderOwner.text = notification.orderOwnerName
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let receiveDate = formatter.date(from: notification.receiveTime)
        let dueDate = formatter.date(from: notification.dueTime)
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let receiveTimeString = formatter.string(from: receiveDate!)
        let dueTimeString = formatter.string(from: dueDate!)

        self.labelReceiveTime.text = receiveTimeString
        if notification.dueTime == "" {
            self.labelDueTime.text = "無逾期時間"
        } else {
            self.labelDueTime.text = dueTimeString
        }
        
        self.labelBrandName.text = notification.brandName
        self.labelMemberCount.text = String(notification.attendedMemberCount)
        switch notification.notificationType {
            case NOTIFICATION_TYPE_MESSAGE_DUETIME:
                self.labelNotificationType.text = "團購催訂"
                self.labelNotificationType.textColor = COLOR_PEPPER_RED
                break
                
            case NOTIFICATION_TYPE_MESSAGE_INFORMATION:
                self.labelNotificationType.text = "團購訊息"
                break
                
            case NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
                self.labelNotificationType.text = "團購邀請"
                break
                
            default:
                break
        }

        setupReplyStatus()
    }

    func setupReplyStatus() {
        if self.notificationData.replyStatus != "" {
            var replyString: String = ""
            if self.notificationData.replyTime != "" {
                let formatter = DateFormatter()
                formatter.dateFormat = DATETIME_FORMATTER
                let replyDate = formatter.date(from: self.notificationData.replyTime)!
                
                formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
                replyString = formatter.string(from: replyDate)
            }
            
            switch self.notificationData.replyStatus {
                case MENU_ORDER_REPLY_STATUS_ACCEPT:
                    self.labelReplyStatus.text = "已於 \(replyString) 回覆 參加"
                    break
                
                case MENU_ORDER_REPLY_STATUS_REJECT:
                    self.labelReplyStatus.text = "已於 \(replyString) 回覆 不參加"
                    break
                    
                default:
                    self.labelReplyStatus.text = "尚未回覆"
                    break
            }
        }
    }
}

extension NotificationActionViewController: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        if self.interstitialAd.isReady {
            self.interstitialAd.present(fromRootViewController: self)
        } else {
            print("Interstitial Ad is not ready !!")
        }
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
