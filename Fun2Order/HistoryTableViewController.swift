//
//  HistoryTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    let titlesArray: [String] = ["五十嵐  台南民族店", "柚豆  善化一店", "迷克夏  新市店"]
    let brandImages: [UIImage] = [UIImage(named: "五十嵐.png")!,
                                UIImage(named: "柚豆.jpg")!,
                                UIImage(named: "迷克夏.jpg")!,]
    let groupFlags: [Bool] = [false, true, false]
    let orderTimeArray: [String] = ["2019年10月18日 14:03:05", "2019年10月19日 11:33:05", "2019年10月20日 18:42:33"]
    let orderNoArray: [String] = ["ABC1234567890", "ABC1234567891", "ABC1234567892"]
    let orderContentArray: [String] = ["@  紅茶 半糖 少冰 大杯 @  綠茶 微糖 微冰 大杯 @  紅茶 半糖 少冰 大杯", "@  紅茶 半糖 少冰 大杯 @  綠茶 微糖 微冰 大杯 @  紅茶 半糖 少冰 大杯", "@  紅茶 半糖 少冰 大杯 @  綠茶 微糖 微冰 大杯 @  紅茶 半糖 少冰 大杯"]
    let statusArray: [String] = ["已取餐", "製作中", "訂單成立"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let historyCellViewNib: UINib = UINib(nibName: "OrderHistoryCell", bundle: nil)
        self.tableView.register(historyCellViewNib, forCellReuseIdentifier: "OrderHistoryCell")

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell", for: indexPath) as! OrderHistoryCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.setTitle(title: self.titlesArray[indexPath.row], brand: self.brandImages[indexPath.row])
        cell.setOrderContent(group_order: self.groupFlags[indexPath.row],
                             order_time: self.orderTimeArray[indexPath.row],
                             order_no: self.orderNoArray[indexPath.row],
                             order_content: self.orderContentArray[indexPath.row],
                             status: self.statusArray[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 270
    }
    
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

extension HistoryTableViewController: DisplayQRCodeDelegate {
    func didQRCodeButtonPressed(at index: IndexPath) {
        guard let qrCodeController = self.storyboard?.instantiateViewController(withIdentifier: "QRCode_VC") as? QRCodeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (QRCodeViewController)")
            return
        }
        
        qrCodeController.setQRCodeText(code: self.orderNoArray[index.row])
        qrCodeController.modalTransitionStyle = .crossDissolve
        qrCodeController.modalPresentationStyle = .overFullScreen
        navigationController?.present(qrCodeController, animated: true, completion: nil)
    }
}
