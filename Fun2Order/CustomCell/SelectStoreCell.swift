//
//  SelectStoreCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class SelectStoreCell: UITableViewCell {

    var mainCategories = [String]()
    var subCategories = [[String]]()
    var storeTitles = [[String]]()
    var storeSubTitles = [[String]]()
    var storeIDs = [[Int]]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    var selectedRegionIndex: Int = 0
    var selectedCountyIndex: Int = 0
    var selectedStoreIndexInCounty: Int = 0
    var selectedBrandIndex: Int = 0
    //var selectedBrandProfile: BrandProfile!
    var selectedBrandTitle: String!
    var selectedBrandID: Int!
    var selectedBrandImage: UIImage!
    var selectedStoreID: Int!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var storePicker: UIPickerView!
    @IBOutlet weak var regionSegment: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
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
        
        vc = app.persistentContainer.viewContext
        
        setupDefaultBrandData()
        retrieveCategoryInformation()
        retrieveStoreInformation()
        self.storePicker.reloadAllComponents()
        
        self.regionSegment.selectedSegmentIndex = 0
    }
    
    func retrieveCategoryInformation() {
        let selectedBrandID = getSelectedBrandID()
        if selectedBrandID == 0 {
            return
        }
        
        self.mainCategories.removeAll()
        self.subCategories.removeAll()
        
        let fetchSortRequest: NSFetchRequest<CODE_TABLE> = CODE_TABLE.fetchRequest()
        let predicateString = "codeCategory == \"\(CODE_STORE_CATEGORY)\" AND codeExtension == \"\(selectedBrandID)\""
        print("retrieveCategoryInformation predicateString = \(predicateString)")
        let predicate = NSPredicate(format: predicateString)
        fetchSortRequest.predicate = predicate
        let sort = NSSortDescriptor(key: "index", ascending: true)
        fetchSortRequest.sortDescriptors = [sort]
        
        do {
            let code_list = try vc.fetch(fetchSortRequest)
            for code_data in code_list {
                //print("Fetched code: \(code_data.code!), subCode: \(code_data.subCode!), desc: \(code_data.codeDescription!)")
                if self.mainCategories.isEmpty {
                    self.mainCategories.append(code_data.code!)
                    var tmpSubCategories = [String]()
                    tmpSubCategories.append(code_data.subCode!)
                    self.subCategories.append(tmpSubCategories)
                } else {
                    var isFound = false
                    for i in 0...(self.mainCategories.count - 1) {
                        if self.mainCategories[i] == code_data.code {
                            var tmpSubCategories = subCategories[i]
                            tmpSubCategories.append(code_data.subCode!)
                            self.subCategories[i] = tmpSubCategories
                            isFound = true
                            break
                        }
                    }
                    if !isFound {
                        self.mainCategories.append(code_data.code!)
                        var tmpSubCategories = [String]()
                        tmpSubCategories.append(code_data.subCode!)
                        self.subCategories.append(tmpSubCategories)
                    }
                }
            }
            //print("self.mainCategories = \(self.mainCategories)")
            //print("self.subCategories = \(self.subCategories)")
            refreshRegionSegment()
        } catch {
            print(error.localizedDescription)
        }
    }

    func retrieveStoreInformation() {
        if self.mainCategories.isEmpty {
            return
        }
        
        let selectedBrandID = getSelectedBrandID()
        if selectedBrandID == 0 {
            return
        }
        
        self.storeTitles.removeAll()
        self.storeSubTitles.removeAll()
        
        for i in 0...(self.mainCategories.count - 1) {
            var tmpTitles = [String]()
            var tmpSubTitles = [String]()
            var tmpStoreIDs = [Int]()

            for j in 0...(self.subCategories[i].count - 1) {
                tmpTitles.removeAll()
                tmpSubTitles.removeAll()
                
                let fetchSortRequest: NSFetchRequest<STORE_INFORMATION> = STORE_INFORMATION.fetchRequest()
                let predicateString = "brandID == \(selectedBrandID) AND storeCategory == \"\(self.mainCategories[i])\" AND storeSubCategory == \"\(self.subCategories[i][j])\""

                //print("retrieveStoreInformation predicateString: \(predicateString)")
                let predicate = NSPredicate(format: predicateString)
                fetchSortRequest.predicate = predicate
                let sort = NSSortDescriptor(key: "storeID", ascending: true)
                fetchSortRequest.sortDescriptors = [sort]
                do {
                    let store_list = try vc.fetch(fetchSortRequest)
                    for store_data in store_list {
                        tmpTitles.append(store_data.storeName!)
                        tmpSubTitles.append(store_data.storeDescription!)
                        tmpStoreIDs.append(Int(store_data.storeID))
                        //print("Store Description: \(store_data.storeDescription!)")
                    }
                } catch {
                    print(error.localizedDescription)
                }
                self.storeTitles.append(tmpTitles)
                self.storeSubTitles.append(tmpSubTitles)
                self.storeIDs.append(tmpStoreIDs)
            }
        }
    }

    func refreshRegionSegment() {
        self.regionSegment.removeAllSegments()
        for i in 0...(self.mainCategories.count - 1) {
            self.regionSegment.insertSegment(withTitle: self.mainCategories[i], at: i, animated: true)
        }
        self.regionSegment.selectedSegmentIndex = 0
    }

    func setupDefaultBrandData() {
        let selectedBrandID = getSelectedBrandID()
        if selectedBrandID == 0 {
            self.selectedBrandID = selectedBrandID
            return
        }
        
        self.selectedBrandID = selectedBrandID
        
        let brand_data = retrieveBrandProfile(brand_id: selectedBrandID)
        if brand_data == nil {
            return
        }
        
        self.selectedBrandTitle = brand_data!.brandName!
        self.selectedBrandImage = UIImage(data: brand_data!.brandIconImage!)!
    }
    
    @objc func receiveBrandInfo(_ notification: Notification) {
        if let brandIndex = notification.object as? Int {
            let brand_data = retrieveBrandProfile(brand_id: brandIndex)
            if brand_data == nil {
                return
            }
            
            self.selectedBrandID = brandIndex
            retrieveCategoryInformation()
            retrieveStoreInformation()

            self.selectedBrandTitle = brand_data!.brandName!
            self.selectedBrandImage = UIImage(data: brand_data!.brandIconImage!)!
            self.selectedBrandIndex = brandIndex
            print("SelectStoreCell received brand name: \(self.selectedBrandTitle!)")

            self.selectedCountyIndex = 0
            self.selectedStoreIndexInCounty = 0
            self.storePicker.reloadAllComponents()
            self.storePicker.selectRow(0, inComponent: 0, animated: true)
            self.storePicker.selectRow(0, inComponent: 1, animated: true)
            self.regionSegment.selectedSegmentIndex = 0
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
        if self.selectedBrandID == 0 {
            return
        }
        
        let storeIndex = getStoreIndex(index1: self.selectedRegionIndex, index2: self.selectedCountyIndex)
        
        var favoriteStore = FavoriteStoreInfo()
        favoriteStore.brandID = self.selectedBrandID
        favoriteStore.storeID = self.storeIDs[storeIndex][self.selectedStoreIndexInCounty]
        favoriteStore.brandName = self.selectedBrandTitle
        favoriteStore.storeName = self.storeTitles[storeIndex][self.selectedStoreIndexInCounty]
        favoriteStore.storeDescription = self.storeSubTitles[storeIndex][self.selectedStoreIndexInCounty]
        favoriteStore.storeBrandImage = self.selectedBrandImage
        
        NotificationCenter.default.post(name: NSNotification.Name("AddToFavorite"), object: favoriteStore)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
            if self.subCategories.isEmpty {
                return 0
            }
            
            return self.subCategories[self.selectedRegionIndex].count
        } else {
            if self.subCategories.isEmpty {
                return 0
            }
            
            //let indexSub = self.storePicker.selectedRow(inComponent: 0)
            //let indexSub = self.selectedRegionIndex
            //if indexSub == 0 {
            //    return self.storeTitles[indexSub].count
            //} else {
            let storeIndex = getStoreIndex(index1: self.selectedRegionIndex, index2: self.selectedCountyIndex)
            //print("numberOfRowsInComponent self.storeTitles[storeIndex].count = \(self.storeTitles[storeIndex].count)")
            return self.storeTitles[storeIndex].count
            //}
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
            print("didSelectRow self.selectedCountyIndex = \(self.selectedCountyIndex)")
            print("didSelectRow self.selectedStoreIndexInCounty = \(self.selectedStoreIndexInCounty)")
        } else {
            self.selectedStoreIndexInCounty = row
            print("didSelectRow self.selectedStoreIndexInCounty = \(self.selectedStoreIndexInCounty)")
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
