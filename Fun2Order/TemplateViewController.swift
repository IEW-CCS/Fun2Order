//
//  TemplateViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

protocol MenuTemplateDelegate: class {
    func sendTemplateSelectedIndex(sender: TemplateViewController, type: Int, index: Int)
    func deleteCustomTemplate(sender: TemplateViewController, index: Int)
}

class TemplateViewController: UIViewController {
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonOK: UIButton!
    @IBOutlet weak var segmentType: UISegmentedControl!
    @IBOutlet weak var tableViewTemplate: UITableView!
    
    var templateArray: [String] = [String]()
    var customTemplateArray: [String] = [String]()
    var selectedTemplateIndex: Int = -1
    var selectedTypeIndex: Int = 0
    weak var delegate: MenuTemplateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let titleCellViewNib: UINib = UINib(nibName: "BasicTitleCell", bundle: nil)
        self.tableViewTemplate.register(titleCellViewNib, forCellReuseIdentifier: "BasicTitleCell")

        self.segmentType.selectedSegmentIndex = 0

        self.tableViewTemplate.delegate = self
        self.tableViewTemplate.dataSource = self

    }

    @IBAction func changeTemplateType(_ sender: UISegmentedControl) {
        self.selectedTypeIndex = sender.selectedSegmentIndex
        self.tableViewTemplate.reloadData()
    }
    
    @IBAction func cancelSelect(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmSelect(_ sender: UIButton) {
        if self.selectedTemplateIndex == -1 {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未選擇範本，請重新選擇。")
            return
        }
        
        delegate?.sendTemplateSelectedIndex(sender: self, type: self.selectedTypeIndex, index: self.selectedTemplateIndex)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setData(template_ids: [String], custom_template_ids: [String]) {
        self.templateArray = template_ids
        self.customTemplateArray = custom_template_ids
    }
}

extension TemplateViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTypeIndex == 0 {
            if self.customTemplateArray.isEmpty {
                return 0
            } else {
                return self.customTemplateArray.count
            }
        } else {
            if self.templateArray.isEmpty {
                return 0
            } else {
                return self.templateArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTitleCell", for: indexPath) as! BasicTitleCell
        //cell.selectionStyle = UITableViewCell.SelectionStyle.none

        if selectedTypeIndex == 0 {
            cell.setData(title: self.customTemplateArray[indexPath.row])
        } else {
            cell.setData(title: self.templateArray[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTemplateIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.selectedTypeIndex == 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除自訂範本", message: "確定要刪除此自訂的範本嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this custom recipe template [\(self.selectedTemplateIndex)]")
                //presentSimpleAlertMessage(title: "Test", message: "Delete this template [\(self.customTemplateArray[indexPath.row])]")
                if Auth.auth().currentUser?.uid != nil {
                    let databaseRef = Database.database().reference()
                    if self.customTemplateArray[indexPath.row] == "" {
                        print("self.customTemplateArray[indexPath.row] is empty")
                        return
                    }
                    
                    let pathString = "USER_CUSTOM_RECIPE_TEMPLATE/\(Auth.auth().currentUser!.uid)/\(self.customTemplateArray[indexPath.row])"
                    databaseRef.child(pathString).removeValue(completionBlock: {(error, ref) in
                        if let error = error {
                            presentSimpleAlertMessage(title: "錯誤訊息", message: "刪除自訂範本時發生錯誤：\(error.localizedDescription)")
                            return
                        }
                        self.customTemplateArray.remove(at: indexPath.row)
                        self.delegate?.deleteCustomTemplate(sender: self, index: indexPath.row)
                        self.selectedTemplateIndex = -1
                        self.tableViewTemplate.reloadData()
                    })
                }
                
                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to delete this custom recipe template")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
        }
    }

}

