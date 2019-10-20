//
//  SelectStoreCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class SelectStoreCell: UITableViewCell {
    let brandTitles: [String] = ["上宇林", "丸作", "五十嵐", "公館手作", "迷克夏", "自在軒", "柚豆", "紅太陽", "茶湯會", "圓石", "Teas原味"]
    
    let brandImages: [UIImage] = [
        UIImage(named: "上宇林@3x.jpg")!,
        UIImage(named: "丸作@3x.jpg")!,
        UIImage(named: "五十嵐@3x.png")!,
        UIImage(named: "公館手作@3x.jpg")!,
        UIImage(named: "迷克夏@3x.jpg")!,
        UIImage(named: "自在軒@3x.png")!,
        UIImage(named: "柚豆@3x.jpg")!,
        UIImage(named: "紅太陽@3x.png")!,
        UIImage(named: "茶湯會@3x.jpg")!,
        UIImage(named: "圓石@3x.jpg")!,
        UIImage(named: "Teas原味@3x.jpg")!]
    
    let mainCategories: [String] = ["北部", "中部", "南部", "東部", "離島"]
    
    let subCategories: [[String]] = [["基隆", "新北市", "台北市", "桃園市", "新竹"],
                                ["苗栗", "台中市", "彰化", "南投"],
                                ["雲林", "嘉義", "台南市", "高雄市", "屏東"],
                                ["宜蘭", "花蓮", "台東"],
                                ["馬祖", "金門", "澎湖"]]

    let storeTitles: [[String]] =
        [["基隆01店", "基隆02店", "基隆03店", "基隆04店", "基隆05店", "基隆06店", "基隆07店"],
          ["新北市01店", "新北市02店", "新北市03店", "新北市04店", "新北市05店", "新北市06店"],
          ["台北市01店", "台北市02店", "台北市03店", "台北市04店", "台北市05店", "台北市06店", "台北市07店"],
          ["桃園市1店", "桃園市2店", "桃園市3店", "桃園市4店", "桃園市5店", "桃園市6店", "桃園市7店", "桃園市8店"],
          ["新竹1店", "新竹2店", "新竹3店", "新竹4店", "新竹5店", "新竹6店"],
          ["苗栗1店", "苗栗2店", "苗栗3店"],
          ["台中市1店", "台中市2店", "台中市3店", "台中市4店", "台中市5店", "台中市6店", "台中市7店", "台中市8店"],
          ["彰化1店", "彰化2店"],
          ["南投1店", "南投2店", "南投3店"],
          ["雲林1店", "雲林2店"],
          ["嘉義1店", "嘉義2店", "嘉義3店", "嘉義4店"],
          ["台南市1店", "台南市2店", "台南市3店", "台南市4店", "台南市5店", "台南市6店", "台南市7店"],
          ["高雄市1店", "高雄市2店", "高雄市3店", "高雄市4店", "高雄市5店", "高雄市6店"],
          ["屏東1店", "屏東2店", "屏東3店", "屏東4店", "屏東5店"],
          ["宜蘭1店", "宜蘭2店", "宜蘭3店"],
          ["花蓮1店", "花蓮2店"],
          ["台東1店", "台東2店", "台東3店", "台東4店"],
          ["馬祖1店"],
          ["金門1店"],
          ["澎湖1店"]]
    
    let storeSubTitles: [[String]] =
        [["基隆路段_01", "基隆路段_02", "基隆路段_03", "基隆路段_04", "基隆路段_05", "基隆路段_06", "基隆路段_07"],
        ["新北市路段_01", "新北市路段_02", "新北市路段_03", "新北市路段_04", "新北市路段_05", "新北市路段_06"],
        ["台北市路段_01", "台北市路段_02", "台北市路段_03", "台北市路段_04", "台北市路段_05", "台北市路段_06", "台北市路段_07"],
        ["桃園市路段_01", "桃園市路段_02", "桃園市路段_03", "桃園市路段_04", "桃園市路段_05", "桃園市路段_06", "桃園市路段_07","桃園市路段_08"],
        ["新竹路段_1", "新竹路段_2", "新竹路段_3", "新竹路段_4", "新竹路段_5", "新竹路段_6"],
        ["苗栗路段_1", "苗栗路段_2", "苗栗路段_3"],
        ["台中市路段_1", "台中市路段_2", "台中市路段_3", "台中市路段_4", "台中市路段_5", "台中市路段_6", "台中市路段_7", "台中市路段_8"],
        ["彰化路段_1", "彰化路段_2"],
        ["南投路段_1", "南投路段_2", "南投路段_3"],
        ["雲林路段_1", "雲林路段_2"],
        ["嘉義路段_1", "嘉義路段_2", "嘉義路段_3", "嘉義路段_4"],
        ["台南市路段_1", "台南市路段_2", "台南市路段_3", "台南市路段_4", "台南市路段_5", "台南市路段_6", "台南市路段_7"],
        ["高雄市路段_1", "高雄市路段_2", "高雄市路段_3", "高雄市路段_4", "高雄市路段_5", "高雄市路段_6"],
        ["屏東路段_1", "屏東路段_2", "屏東路段_3", "屏東路段_4", "屏東路段_5"],
        ["宜蘭路段_1", "宜蘭路段_2", "宜蘭路段_3"],
        ["花蓮路段_1", "花蓮路段_2"],
        ["台東路段_1", "台東路段_2", "台東路段_3", "台東路段_4"],
        ["馬祖路段_1"],
        ["金門路段_1"],
        ["澎湖路段_1"]]
    
    var selectedRegionIndex: Int = 0
    var selectedCountyIndex: Int = 0
    var selectedStoreIndexInCounty: Int = 0
    var selectedBrandIndex: Int = 0
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var storePicker: UIPickerView!
    @IBOutlet weak var regionSegment: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        //self.backView.layer.borderColor = UIColor.lightGray.cgColor
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 6
        
        let iconImage: UIImage? = UIImage(named: "Icon_Favorite_Button.png")
        self.favoriteButton.setImage(iconImage, for: UIControl.State.normal)
        
        self.storePicker.delegate = self
        self.storePicker.dataSource = self
        
        
        self.storePicker.selectRow(0, inComponent: 0, animated: true)
        self.storePicker.selectRow(0, inComponent: 1, animated: true)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveBrandInfo(_:)),
            name: NSNotification.Name(rawValue: "BrandInfo"),
            object: nil
        )

    }
    
    @objc func receiveBrandInfo(_ notification: Notification) {
        if let brandIndex = notification.object as? Int {
            print("SelectStoreCell received brand name: \(self.brandTitles[brandIndex])")
            self.selectedBrandIndex = brandIndex
        }
    }

    @IBAction func selectRegion(_ sender: UISegmentedControl) {
        print("Selected region index = \(self.regionSegment.selectedSegmentIndex)")
        self.selectedRegionIndex = self.regionSegment.selectedSegmentIndex
        self.selectedCountyIndex = 0
        self.selectedStoreIndexInCounty = 0
        self.storePicker.reloadAllComponents()
        self.storePicker.selectRow(0, inComponent: 0, animated: true)
        self.storePicker.selectRow(0, inComponent: 1, animated: true)
    }
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        let storeIndex = getStoreIndex(index1: self.selectedRegionIndex, index2: self.selectedCountyIndex)
        
        var favoriteStore = FavoriteStoreInfo()
        favoriteStore.storeName = self.storeTitles[storeIndex][self.selectedStoreIndexInCounty]
        favoriteStore.storeAddressInfo = self.storeSubTitles[storeIndex][self.selectedStoreIndexInCounty]
        favoriteStore.storeBrandImage = self.brandImages[self.selectedBrandIndex]
        
        NotificationCenter.default.post(name: NSNotification.Name("AddToFavorite"), object: favoriteStore)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension SelectStoreCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    private func getStoreIndex(index1: Int, index2: Int) -> Int {
        var sum: Int = 0
        var storeIndex: Int = 0
        
        if index1 == 0 {
            return index2
        }
        
        for i in 0...index1 - 1 {
            sum = sum + self.subCategories[i].count
        }
        
        storeIndex = sum + index2
        
        return storeIndex
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.subCategories[self.selectedRegionIndex].count
        } else {
            //let indexSub = self.storePicker.selectedRow(inComponent: 0)
            let indexSub = self.selectedRegionIndex
            if indexSub == 0 {
                return self.storeTitles[indexSub].count
            } else {
                let storeIndex = getStoreIndex(index1: self.selectedRegionIndex, index2: self.selectedCountyIndex)
                //print("numberOfRowsInComponent self.storeTitles[storeIndex].count = \(self.storeTitles[storeIndex].count)")
                return self.storeTitles[storeIndex].count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return self.subCategories[self.selectedRegionIndex][row]
        } else {
            let storeIndex = getStoreIndex(index1: self.selectedRegionIndex, index2: self.selectedCountyIndex)
            return self.storeTitles[storeIndex][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.selectedCountyIndex = row
            self.storePicker.reloadComponent(1)
            self.storePicker.selectRow(0, inComponent: 1, animated: true)
            self.selectedStoreIndexInCounty = self.storePicker.selectedRow(inComponent: 1)
            print("didSelectRow self.selectedStoreIndexInCounty = \(self.selectedStoreIndexInCounty)")
        } else {
            self.selectedStoreIndexInCounty = row
        }
    }
    
    /*
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var title = UILabel()
        
        if let v = view as? UILabel { title = v }
        title.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        title.textColor = UIColor.blue
        title.textAlignment = .center
        
        if component == 0 {
            title.text = self.gatewayArray[row]
        } else {
            let selectedIndex = self.devicePicker.selectedRow(inComponent: 0)
            title.text = self.deviceArray[selectedIndex][row]
        }
        
        return title
    }
    */
}
