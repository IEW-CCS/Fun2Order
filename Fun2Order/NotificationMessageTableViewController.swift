//
//  NotificationMessageTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class NotificationMessageTableViewController: UITableViewController {

    @IBOutlet weak var labelNotificationType: UILabel!
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var labelOwner: UILabel!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var labelDueTime: UILabel!
    @IBOutlet weak var labelAttendedCount: UILabel!
    @IBOutlet weak var textViewMessage: UITextView!
    
    var notificationData: NotificationData = NotificationData()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textViewMessage.layer.borderWidth = 1.0
        self.textViewMessage.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewMessage.layer.cornerRadius = 6
    }

    override func viewWillAppear(_ animated: Bool) {
        setData(notification: self.notificationData)
    }

    func setData(notification: NotificationData) {
        self.labelOwner.text = notification.orderOwnerName
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let receiveDate = formatter.date(from: notification.receiveTime)
        let dueDate = formatter.date(from: notification.dueTime)
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let receiveTimeString = formatter.string(from: receiveDate!)
        let dueTimeString = formatter.string(from: dueDate!)

        self.labelStartTime.text = receiveTimeString
        if notification.dueTime == "" {
            self.labelDueTime.text = "無逾期時間"
        } else {
            self.labelDueTime.text = dueTimeString
        }
        
        self.labelBrandName.text = notification.brandName
        self.labelAttendedCount.text = String(notification.attendedMemberCount)
        switch notification.notificationType {
            case NOTIFICATION_TYPE_MESSAGE_DUETIME:
                self.labelNotificationType.text = "團購催訂"
                self.labelNotificationType.textColor = COLOR_PEPPER_RED
                break
                
            case NOTIFICATION_TYPE_MESSAGE_INFORMATION:
                self.labelNotificationType.text = "訊息內容"
                break
                
            case NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
                self.labelNotificationType.text = "團購邀請"
                break
                
            default:
                break
        }

        textViewMessage.text = notification.messageDetail
    }

/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
