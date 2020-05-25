//
//  TemplateViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuTemplateDelegate: class {
    func sendTemplateSelectedIndex(sender: TemplateViewController, type: Int, index: Int)
}

class TemplateViewController: UIViewController {
    @IBOutlet weak var templatePickerView: UIPickerView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonOK: UIButton!
    @IBOutlet weak var segmentType: UISegmentedControl!
    
    var templateArray: [String] = [String]()
    var customTemplateArray: [String] = [String]()
    var selectedTemplateIndex: Int = 0
    var selectedTypeIndex: Int = 0
    weak var delegate: MenuTemplateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentType.selectedSegmentIndex = 0
        self.templatePickerView.delegate = self
        self.templatePickerView.dataSource = self
    }

    @IBAction func changeTemplateType(_ sender: UISegmentedControl) {
        self.selectedTypeIndex = sender.selectedSegmentIndex
        self.templatePickerView.reloadAllComponents()
    }
    
    @IBAction func cancelSelect(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmSelect(_ sender: UIButton) {
        delegate?.sendTemplateSelectedIndex(sender: self, type: self.selectedTypeIndex, index: self.selectedTemplateIndex)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setData(template_ids: [String], custom_template_ids: [String]) {
        self.templateArray = template_ids
        self.customTemplateArray = custom_template_ids
        self.templatePickerView.reloadAllComponents()
    }
}

extension TemplateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.selectedTypeIndex == 0 {
            if !self.customTemplateArray.isEmpty {
                return self.customTemplateArray.count
            }
        } else if self.selectedTypeIndex == 1 {
            if !self.templateArray.isEmpty {
                return self.templateArray.count
            }
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.selectedTypeIndex == 0 {
            return self.customTemplateArray[row]
        } else if self.selectedTypeIndex == 1 {
            return self.templateArray[row]
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedTemplateIndex = row
        print("TemplateViewController self.selectedTemplateIndex = \(self.selectedTemplateIndex)")
    }
}

