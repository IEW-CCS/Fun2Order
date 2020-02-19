//
//  TemplateViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class TemplateViewController: UIViewController {
    @IBOutlet weak var templatePickerView: UIPickerView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonOK: UIButton!
    
    var templateArray: [String] = [String]()
    var selectedTemplateIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.templatePickerView.delegate = self
        self.templatePickerView.dataSource = self
    }

    @IBAction func cancelSelect(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmSelect(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("SelectTemplate"), object: self.selectedTemplateIndex)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setData(template_ids: [String]) {
        self.templateArray = template_ids
        self.templatePickerView.reloadAllComponents()
    }
}

extension TemplateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if !self.templateArray.isEmpty {
            return self.templateArray.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.templateArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedTemplateIndex = row
        print("TemplateViewController self.selectedTemplateIndex = \(self.selectedTemplateIndex)")
    }
}
