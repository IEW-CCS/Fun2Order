//
//  GenderViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class GenderViewController: UIViewController {
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    let genderArray = ["男性", "女性", "其他"]
    var selectedGenderIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.genderPickerView.delegate = self
        self.genderPickerView.dataSource = self
    }

    public func getGender() -> String {
        return self.genderArray[self.selectedGenderIndex]
    }
}

extension GenderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genderArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedGenderIndex = row
        print("GenderViewController self.selectedGenderIndex = \(self.selectedGenderIndex)")
    }
}
