//
//  BrandListCollectionViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/14.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase

protocol BrandListDelegate: class {
    func getBrandInformation(sender: BrandListCollectionViewController, info: BrandTemplate)
}

class BrandListCollectionViewController: UICollectionViewController, UITextFieldDelegate {
    var brandList: [DetailBrandCategory] = [DetailBrandCategory]()
    var searchBrandList: [DetailBrandCategory] = [DetailBrandCategory]()
    var brandImageList: [UIImage] = [UIImage]()
    var searchBrandImageList: [UIImage] = [UIImage]()
    weak var delegate: BrandListDelegate?
    var searchedFlag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellViewNib: UINib = UINib(nibName: "BrandCollectionViewCell", bundle: nil)
        self.collectionView.register(cellViewNib, forCellWithReuseIdentifier: "BrandCollectionViewCell")
        
        let headerViewNib: UINib = UINib(nibName: "BrandHeaderView", bundle: nil)
        self.collectionView.register(headerViewNib, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "BrandHeaderView")
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 5
        collectionView.collectionViewLayout = layout
        self.tabBarController?.title = self.title
        downloadFBBrandCategoryList()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "品牌列表"
        self.navigationController?.title = "品牌列表"
        self.tabBarController?.title = "品牌列表"
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    func downloadFBBrandCategoryList() {
        self.brandList.removeAll()

        let databaseRef = Database.database().reference()
        let pathString = "BRAND_CATEGORY"

        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let childEnumerator = snapshot.children
                
                let childDecoder: JSONDecoder = JSONDecoder()
                while let childData = childEnumerator.nextObject() as? DataSnapshot {
                    do {
                        let childJsonData = try? JSONSerialization.data(withJSONObject: childData.value as Any, options: [])
                        let realData = try childDecoder.decode(DetailBrandCategory.self, from: childJsonData!)
                        self.brandList.append(realData)
                    } catch {
                        print("downloadFBBrandCategoryList jsonData decode failed: \(error.localizedDescription)")
                        continue
                    }
                }
                
                if !self.brandList.isEmpty {
                    self.brandImageList = Array(repeating: UIImage(), count: self.brandList.count)
                }
                self.searchBrandList = self.brandList
                //print("self.searchBrandList = \(self.searchBrandList)")
                self.searchBrandImageList = self.brandImageList
                
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }) { (error) in
            print("downloadFBBrandCategoryList: \(error.localizedDescription)")
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.searchedFlag {
            if self.searchBrandList.isEmpty {
                return 0
            }
            
            //print("self.searchedFlag is true, return searchBrandList count = \(self.searchBrandList.count)")
            return self.searchBrandList.count
        } else {
            if self.brandList.isEmpty {
                return 0
            }
            
            //print("self.searchedFlag is false, return brandList count = \(self.brandList.count)")
            return self.brandList.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrandCollectionViewCell", for: indexPath) as! BrandCollectionViewCell
    
        if self.searchedFlag {
            cell.setData(brand_name: self.searchBrandList[indexPath.row].brandName, icon: self.searchBrandImageList[indexPath.row], index: indexPath.row)
            cell.delegate = self

        } else {
            cell.setData(brand_name: self.brandList[indexPath.row].brandName, brand_image: self.brandList[indexPath.row].brandIconImage, index: indexPath.row)
            cell.delegate = self
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let detailBrandController = storyBoard.instantiateViewController(withIdentifier: "DETAIL_BRAND_VC") as? DetailBrandTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: DETAIL_BRAND_VC can't find!! (BrandListCollectionViewController)")
            return
        }

        if self.searchedFlag {
            detailBrandController.setData(brand_name: self.searchBrandList[indexPath.row].brandName, brand_image: self.searchBrandImageList[indexPath.row])
        } else {
            detailBrandController.setData(brand_name: self.brandList[indexPath.row].brandName, brand_image: self.brandImageList[indexPath.row])
        }
        
        navigationController?.show(detailBrandController, sender: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "BrandHeaderView", for: indexPath) as! BrandHeaderView
        headerView.delegate = self
        headerView.setData(items: ["茶飲類"])
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: CGFloat(110.0))
    }
}

extension BrandListCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 90)
    }
}


extension BrandListCollectionViewController: BrandCollectionCellDelegate {
    func getBrandImage(sender: BrandCollectionViewCell, icon: UIImage?, index: Int) {
        var iconImage: UIImage = UIImage()
        if icon != nil {
            iconImage = icon!
        }
        self.brandImageList[index] = iconImage
    }
}

extension BrandListCollectionViewController: BrandHeaderDelegate {
    func suggestNewBrand(sender: BrandHeaderView) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let suggestionController = storyBoard.instantiateViewController(withIdentifier: "BRAND_SUGGESTION_VC") as? BrandSuggestionTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: BRAND_SUGGESTION_VC can't find!! (BrandListCollectionViewController)")
            return
        }

        navigationController?.show(suggestionController, sender: self)
    }
    
    func searchBrandRequest(sender: BrandHeaderView, searchText: String) {
        //print("BrandListCollectionViewController received searchBrandRequest")
        print("BrandListCollectionViewController searchText: \(searchText)")
        if self.brandList.isEmpty {
            return
        }
        
        if searchText == "" {
            self.searchedFlag = false
            self.searchBrandList = self.brandList
            self.searchBrandImageList = self.brandImageList
        } else {
            self.searchedFlag = true
            self.searchBrandList.removeAll()
            self.searchBrandImageList.removeAll()
            
            for i in 0...self.brandList.count - 1  {
                if self.brandList[i].brandName.contains(searchText) {
                    self.searchBrandList.append(self.brandList[i])
                    self.searchBrandImageList.append(self.brandImageList[i])
                }
            }
        }
        
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}
