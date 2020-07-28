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
import GoogleMobileAds

protocol BrandListDelegate: class {
    func getBrandInformation(sender: BrandListCollectionViewController, info: BrandTemplate)
}

class BrandListCollectionViewController: UICollectionViewController, UITextFieldDelegate {
    var brandList: [DetailBrandListStruct] = [DetailBrandListStruct]()
    var filterBrandList: [DetailBrandListStruct] = [DetailBrandListStruct]()
    var searchBrandList: [DetailBrandListStruct] = [DetailBrandListStruct]()
    var brandCategoryList: [String] = ["茶飲類"]
    weak var delegate: BrandListDelegate?
    var searchedFlag: Bool = false
    var refreshControl = UIRefreshControl()
    var selectedIndex: Int = 0
    var bannerView: GADBannerView!

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
        
        self.collectionView.alwaysBounceVertical = true
        self.refreshControl.attributedTitle = NSAttributedString(string: "正在更新品牌列表")
        self.refreshControl.addTarget(self, action: #selector(self.refreshBrandList), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)

        //self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(self.bannerView)
        
        downloadFBBrandCategoryList()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "品牌列表"
        self.navigationController?.title = "品牌列表"
        self.tabBarController?.title = "品牌列表"
        reloadBannerAd()
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bannerView)
        view.addConstraints([NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
        
        bannerView.adUnitID = NOTIFICATIONLIST_BANNER_AD
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func reloadBannerAd() {
        bannerView.adUnitID = NOTIFICATIONLIST_BANNER_AD
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    @objc func refreshBrandList() {
        print("Refresh brand List...")
        downloadFBBrandCategoryList()
    }
    
    func prepareBrandCategoryList() {
        if self.brandList.isEmpty {
            print("self.brandList is empty, no need to prepare brand category list")
            return
        }
        
        self.brandCategoryList.removeAll()
        for i in 0...self.brandList.count - 1 {
            if self.brandList[i].brandData.brandCategory ==  nil {
                continue
            }
            
            if !self.brandCategoryList.contains(self.brandList[i].brandData.brandCategory!) {
                self.brandCategoryList.append(self.brandList[i].brandData.brandCategory!)
            }
        }
    }
    
    func filteredBrandListByCategory() {
        if self.brandList.isEmpty {
            print("self.brandList is empty, no need to filter brand list")
            return
        }
        
        self.filterBrandList.removeAll()
        
        for i in 0...self.brandList.count - 1 {
            if self.brandList[i].brandData.brandCategory ==  nil {
                continue
            }

            if self.brandList[i].brandData.brandCategory! == self.brandCategoryList[self.selectedIndex] {
                self.filterBrandList.append(self.brandList[i])
            }
        }
    }

    func downloadFBBrandCategoryList() {
        self.brandList.removeAll()

        let databaseRef = Database.database().reference()
        let pathString = "BRAND_CATEGORY"

        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let childEnumerator = snapshot.children
                
                let childDecoder: JSONDecoder = JSONDecoder()
                var index: Int = 0
                while let childData = childEnumerator.nextObject() as? DataSnapshot {
                    do {
                        let childJsonData = try? JSONSerialization.data(withJSONObject: childData.value as Any, options: [])
                        let realData = try childDecoder.decode(DetailBrandCategory.self, from: childJsonData!)
                        var brandData: DetailBrandListStruct = DetailBrandListStruct()
                        brandData.brandData = realData
                        brandData.index = index
                        self.brandList.append(brandData)
                        index = index + 1
                    } catch {
                        print("downloadFBBrandCategoryList jsonData decode failed: \(error.localizedDescription)")
                        continue
                    }
                }
                
                self.prepareBrandCategoryList()
                self.filteredBrandListByCategory()

                self.searchBrandList = self.filterBrandList

                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.refreshControl.endRefreshing()
            }
        }) { (error) in
            print("downloadFBBrandCategoryList: \(error.localizedDescription)")
            self.refreshControl.endRefreshing()
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
            
            return self.searchBrandList.count
        } else {
            if self.filterBrandList.isEmpty {
                return 0
            }
            
            return self.filterBrandList.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrandCollectionViewCell", for: indexPath) as! BrandCollectionViewCell
    
        if self.searchedFlag {
            cell.setData(brand_data: self.searchBrandList[indexPath.row], index: self.searchBrandList[indexPath.row].index)
            cell.delegate = self

        } else {
            cell.setData(brand_data: self.filterBrandList[indexPath.row], index: self.filterBrandList[indexPath.row].index)
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
            detailBrandController.setData(brand_name: self.searchBrandList[indexPath.row].brandData.brandName, brand_image: self.searchBrandList[indexPath.row].brandImage)
        } else {
            detailBrandController.setData(brand_name: self.filterBrandList[indexPath.row].brandData.brandName, brand_image: self.filterBrandList[indexPath.row].brandImage)
        }
        
        navigationController?.show(detailBrandController, sender: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "BrandHeaderView", for: indexPath) as! BrandHeaderView
        headerView.delegate = self
        headerView.setData(items: self.brandCategoryList, select_index: self.selectedIndex)
        
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
        self.brandList[index].brandImage = iconImage
        if let filterIndex = self.filterBrandList.firstIndex(where: { $0.index == index }) {
            print("The first index = \(filterIndex)")
            self.filterBrandList[filterIndex].brandImage = iconImage
        }
        //filteredBrandListByCategory()
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
        print("BrandListCollectionViewController searchText: \(searchText)")
        if self.filterBrandList.isEmpty {
            return
        }
        
        if searchText == "" {
            self.searchedFlag = false
            self.searchBrandList = self.filterBrandList
        } else {
            self.searchedFlag = true
            self.searchBrandList.removeAll()
            
            for i in 0...self.filterBrandList.count - 1  {
                if self.filterBrandList[i].brandData.brandName.contains(searchText) {
                    self.searchBrandList.append(self.filterBrandList[i])
                }
            }
        }
        
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func changeBrandCategory(sender: BrandHeaderView, index: Int) {
        self.selectedIndex = index
        
        filteredBrandListByCategory()
        
        //self.collectionView.reloadData()
        let indexSet = IndexSet(integer: 0)
        self.collectionView.reloadSections(indexSet)
        self.collectionView.collectionViewLayout.invalidateLayout()

    }
}

extension BrandListCollectionViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        bannerView.alpha = 1
        UIView.animate(withDuration: 1, animations: {
          bannerView.alpha = 1
        })
        //self.isAdLoadedSuccess = true
        //self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
        //self.isAdLoadedSuccess = false
        //self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        //self.tableView.reloadData()
    }
}
