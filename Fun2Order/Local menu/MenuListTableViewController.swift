//
//  MenuListTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class MenuListTableViewController: UITableViewController {
    var menuBrandCategory:[String] = [String]()
    var menuInfos:[MenuInformation] = [MenuInformation]()
    var menuInfosByCategory:[MenuInformation] = [MenuInformation]()
    var createMenuController: CreateMenuTableViewController!
    var selectedIndex: Int = 0
    var segmentItemData: [String] = [String]()

    var adLoader: GADAdLoader!
    var nativeAd: GADUnifiedNativeAd!
    // Test NativeAd Unit ID
    //let adUnitID = "ca-app-pub-3940256099942544/3986624511"
    // James Real NativeAd Unit ID
    //let adUnitID = "ca-app-pub-9511677579097261/2673063242"

    // IEW Real NativeAd Unit ID
    let adUnitID = "ca-app-pub-6672968234138119/7456638522"

    var adIndex: Int = 0
    var heightConstraint : NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let favoriteCellViewNib: UINib = UINib(nibName: "FavoriteStoreCell", bundle: nil)
        self.tableView.register(favoriteCellViewNib, forCellReuseIdentifier: "FavoriteStoreCell")

        let adCellViewNib: UINib = UINib(nibName: "MenuHomeNativeAdCell", bundle: nil)
        self.tableView.register(adCellViewNib, forCellReuseIdentifier: "MenuHomeNativeAdCell")

        let categoryCellViewNib: UINib = UINib(nibName: "MenuListCategoryCell", bundle: nil)
        self.tableView.register(categoryCellViewNib, forCellReuseIdentifier: "MenuListCategoryCell")

        setupAdLoader()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
        self.title = "菜單首頁"
        self.navigationController?.title = "菜單首頁"
        self.tabBarController?.title = "菜單首頁"
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        //showMyProfileTabBarToolTip()
    }

    func downloadFBMenuInformationList(select_index: Int) {
        guard let user_id = Auth.auth().currentUser?.uid else {
            print("Not authorized user, cannot get Menu Information List")
            return
        }

        self.menuInfos.removeAll()

        let databaseRef = Database.database().reference()
        let pathString = "USER_MENU_INFORMATION/\(user_id)"

        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let childEnumerator = snapshot.children
                
                let childDecoder: JSONDecoder = JSONDecoder()
                while let childData = childEnumerator.nextObject() as? DataSnapshot {
                    //print("child = \(childData)")
                    do {
                        let childJsonData = try? JSONSerialization.data(withJSONObject: childData.value as Any, options: [])
                        let realData = try childDecoder.decode(MenuInformation.self, from: childJsonData!)
                        self.menuInfos.append(realData)
                        print("Success: \(realData.brandName)")
                    } catch {
                        print("downloadFBMenuInformationList jsonData decode failed: \(error.localizedDescription)")
                        continue
                    }
                }
                self.menuInfos.sort(by: {$0.createTime > $1.createTime})

                self.menuBrandCategory = retrieveMenuBrandCategory()
                self.selectedIndex = select_index
                self.filterMenuInfosByCategory()
                self.tableView.reloadData()

                let app = UIApplication.shared.delegate as! AppDelegate
                app.toolTipDelegate?.triggerCreateMenuTooltip(parent: self.view)
                self.showMyProfileTabBarToolTip()

            } else {
                //self.tableView.reloadData()
                print("downloadFBMenuInformationList snapshot doesn't exist!")
                let app = UIApplication.shared.delegate as! AppDelegate
                app.toolTipDelegate?.triggerCreateMenuTooltip(parent: self.view)
                self.filterMenuInfosByCategory()
                self.tableView.reloadData()

                return
            }
        }) { (error) in
            print("downloadFBMenuInformationList: \(error.localizedDescription)")
        }
    }
    
    func showMyProfileTabBarToolTip() {
        if self.menuInfos.isEmpty {
            print("showMyProfileTabBarToolTip -> self.menuInfos is Empty")
            return
        } else {
            if self.menuInfos.count > 1 {
                print("showMyProfileTabBarToolTip -> self.menuInfos.count = [\(self.menuInfos.count)]")
                return
            }
        }
        
        let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"
        let plist = NSMutableDictionary(contentsOfFile: path)
        let toolTipOption = plist!["ToolTipOption"] as! Bool
        let myProfileToolTip = plist!["showedMyProfileToolTip"] as! Bool

        print("toolTipOption =  \(toolTipOption)")
        print("myProfileToolTip = \(myProfileToolTip)")
        
        if toolTipOption == true && myProfileToolTip == false {
            let app = UIApplication.shared.delegate as! AppDelegate

            var tmpViews: [UIView] = [UIView]()
            if let tabViews = app.myTabBar?.subviews {
                tmpViews = tabViews.sorted(by: {$0.frame.minX > $1.frame.minX})
            }
            
            let myProfileView = tmpViews[0]
            DispatchQueue.main.async {
                showGuideToolTip(text: "恭喜您完成第一張菜單\n接下來請從這裡\n加入您的好友並建立群組\n之後就可使用揪團功能", dir: PopTipDirection.up, parent: app.myTabBar!, target: myProfileView.frame, duration: 8)
            }

            if let writePlist = NSMutableDictionary(contentsOfFile: path) {
                writePlist["showedMyProfileToolTip"] = true
                if writePlist.write(toFile: path, atomically: true) {
                    print("Write showedMyProfileToolTip to GuideToolTip.plist successfule.")
                } else {
                    print("Write showedMyProfileToolTip to GuideToolTip.plist failed.")
                }
            }

        }

    }

    func filterMenuInfosByCategory() {
        self.menuInfosByCategory.removeAll()
        // Add empty MenuInformation for NativeAd
        let tmpMenuInfo: MenuInformation = MenuInformation()
        self.menuInfosByCategory.append(tmpMenuInfo)  //Add an empty menu information for Ad cell
        self.adIndex = 0
        
        
        if !self.menuInfos.isEmpty {
            var categoryString: String = ""
            if self.selectedIndex != self.menuBrandCategory.count {
                categoryString = self.menuBrandCategory[self.selectedIndex]
            }
            
            for i in 0...self.menuInfos.count - 1 {
                if self.menuInfos[i].brandCategory == categoryString {
                    self.menuInfosByCategory.append(self.menuInfos[i])
                }
            }
        }
    }
    
    func getMenuCountForCategory() -> Int {
        var returnCount: Int = 0
        
        if self.menuBrandCategory.isEmpty {
            return self.menuInfos.count
        } else {
            var categoryString: String = ""
            if self.selectedIndex != self.menuBrandCategory.count {
                categoryString = self.menuBrandCategory[self.selectedIndex]
            }

            for i in 0...self.menuInfos.count - 1 {
                if self.menuInfos[i].brandCategory == categoryString {
                    returnCount = returnCount + 1
                }
            }
        }
        
        print("getMenuCountForCategory returnCount = \(returnCount)")
        return returnCount
    }

    func deleteMenuInfo(index: IndexPath) {
        deleteMenuIcon(menu_number: self.menuInfosByCategory[index.row].menuNumber)
        //deleteFBMenuInformation(user_id: self.menuInfosByCategory[index.row].userID, menu_number: self.menuInfosByCategory[index.row].menuNumber, image_url: self.menuInfosByCategory[index.row].menuImageURL)
        deleteFBMenuInformation(menu_info: self.menuInfosByCategory[index.row])

        print("MenuListTableViewController deleteMenuInfo downloadFBMenuInformationList")
        downloadFBMenuInformationList(select_index: self.selectedIndex)
    }
    
    func setupAdLoader() {
        //let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        //multipleAdsOptions.numberOfAds = 3

        self.adLoader = GADAdLoader(adUnitID: self.adUnitID, rootViewController: self, adTypes: [.unifiedNative], options: nil)
        //self.adLoader = GADAdLoader(adUnitID: self.adUnitID, rootViewController: self, adTypes: [.unifiedNative], options: [multipleAdsOptions])
        self.adLoader.load(GADRequest())
        self.adLoader.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //if self.menuInfos.isEmpty {
        //    return 1
        //}
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            //if self.menuInfos.isEmpty {
            //    return 0
            //}
            
            //print("numberOfRowsInSection is : [\(self.menuInfosByCategory.count)]")
            if self.menuInfosByCategory.isEmpty {
                return 0
            } else {
                return self.menuInfosByCategory.count
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuListCategoryCell", for: indexPath) as! MenuListCategoryCell
            
            if self.menuInfos.isEmpty {
                cell.setData(menu_exist_flag: false, items: self.menuBrandCategory, selected_index: self.selectedIndex)
            } else {
                cell.setData(menu_exist_flag: true, items: self.menuBrandCategory, selected_index: self.selectedIndex)
            }
            
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        }
        
        if indexPath.row == self.adIndex {
            self.nativeAd.rootViewController = self
            heightConstraint?.isActive = false

            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuHomeNativeAdCell", for: indexPath) as! MenuHomeNativeAdCell
            
            let adView: GADUnifiedNativeAdView = cell.contentView.subviews.first as! GADUnifiedNativeAdView
            adView.nativeAd = self.nativeAd

            adView.mediaView?.mediaContent = self.nativeAd.mediaContent
            adView.mediaView?.contentMode = .scaleAspectFit
            let mediaContent = nativeAd.mediaContent
            if mediaContent.hasVideoContent {
                mediaContent.videoController.delegate = self
            }
            
            (adView.headlineView as! UILabel).text = nativeAd.headline
            (adView.advertiserView as! UILabel).text = nativeAd.advertiser
            (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
            //(adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            if nativeAd.callToAction == "INSTALL" {
                (adView.callToActionView as? UIButton)?.setTitle("安裝", for: .normal)
            } else {
                (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            }
            adView.callToActionView?.isHidden = nativeAd.callToAction == nil
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteStoreCell", for: indexPath) as! FavoriteStoreCell
        
        let menuIcon = retrieveMenuIcon(menu_number: self.menuInfosByCategory[indexPath.row].menuNumber)
        cell.setData(brand_image: menuIcon,
                     title: self.menuInfosByCategory[indexPath.row].brandName,
                     sub_title: self.menuInfosByCategory[indexPath.row].menuDescription)

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        cell.indexPath = indexPath

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        } else {
            if indexPath.row == self.adIndex {
                return 190
            }
            
            return 100
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row != self.adIndex {
                let cell = self.tableView.cellForRow(at: indexPath) as! FavoriteStoreCell

                let dataIndex = cell.indexPath
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let menuCreateController = storyBoard.instantiateViewController(withIdentifier: "CREATEMENU_VC") as? CreateMenuTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: CREATEMENU_VC can't find!! (QRCodeViewController)")
                    return
                }
                menuCreateController.isEditedMode = true
                menuCreateController.menuInformation = menuInfosByCategory[dataIndex!.row]
                menuCreateController.delegate = self
                
                navigationController?.show(menuCreateController, sender: self)
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            if indexPath.row == self.adIndex {
                return false
            }
            
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除菜單", message: "確定要刪除此菜單嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this menu")
                self.deleteMenuInfo(index: indexPath)
                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to delete the menu")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
        }
    }
    
}

extension MenuListTableViewController: DisplayGroupOrderDelegate {
    func didGroupButtonPressed(at index: IndexPath) {
        let groupList = retrieveGroupList()
        if groupList.isEmpty{
            presentSimpleAlertMessage(title: "提示訊息", message: "您尚未建立任何群組，請至\n『我的設定』--> 『群組資訊』中\n先建立群組並加入好友\n之後即可開始使用揪團功能")
            return
        }

        guard let groupOrderController = self.storyboard?.instantiateViewController(withIdentifier: "GroupOrder_VC") as? GroupOrderViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (MenuListTableViewController)")
            return
        }
        groupOrderController.orderType = ORDER_TYPE_MENU
        groupOrderController.menuInformation = self.menuInfosByCategory[index.row]
        navigationController?.show(groupOrderController, sender: self)
    }
}

extension MenuListTableViewController: ScrollUISegmentControllerDelegate {
    func selectItemAt(index: Int, onScrollUISegmentController scrollUISegmentController: ScrollUISegmentController) {
        print("select Item At [\(index)] in scrollUISegmentController with tag  \(scrollUISegmentController.tag) ")
        self.selectedIndex = index
        filterMenuInfosByCategory()
        //setupAdLoader()
        self.tableView.reloadData()
    }
}

extension MenuListTableViewController: CreateMenuDelegate {
    func refreshMenuList(sender: CreateMenuTableViewController) {
        print("MenuListTableViewController receive CreateMenuDelegate refreshMenuList")
        downloadFBMenuInformationList(select_index: self.selectedIndex)
    }
}

extension MenuListTableViewController: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        downloadFBMenuInformationList(select_index: 0)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        print("Received native ad: \(nativeAd)")
        self.nativeAd = nativeAd
        downloadFBMenuInformationList(select_index: 0)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("adLoader Did Finish Loading!!")
    }
}

extension MenuListTableViewController : GADVideoControllerDelegate {
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        print("Video playback has ended.")
    }
}

extension MenuListTableViewController: MenuListCategoryCellDelegate {
    func categoryIndexChanged(sender: MenuListCategoryCell, index: Int) {
        self.selectedIndex = index
        self.filterMenuInfosByCategory()
        let sectionIndex = IndexSet(integer: 1)
        self.tableView.reloadSections(sectionIndex, with: .none)
    }
    
    func displayAbout(sender: MenuListCategoryCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Banner_VC") as? BannerDetailViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: Banner_VC can't find!! (ViewController)")
            return
        }
        
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func displayCreateMenu(sender: MenuListCategoryCell) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let menuCreateController = storyBoard.instantiateViewController(withIdentifier: "CREATEMENU_VC") as? CreateMenuTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: CREATEMENU_VC can't find!! (QRCodeViewController)")
            return
        }
        
        menuCreateController.delegate = self
        navigationController?.show(menuCreateController, sender: self)
    }
    
    func deleteBrandCategory(sender: MenuListCategoryCell) {
        //presentSimpleAlertMessage(title: "Test", message: "Long Press to delete brand category")
        let controller = UIAlertController(title: "編輯分類", message: nil, preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "刪除分類", style: .default) { (_) in
            //presentSimpleAlertMessage(title: "Test", message: "Confirm to delete, pop-up another view controller")
            let controller = UIAlertController(title: "刪除分類", message: nil, preferredStyle: .alert)

            let brandCategoryList = retrieveMenuBrandCategory()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            guard let brandCategoryController = storyBoard.instantiateViewController(withIdentifier: "BRANDCATEGORY_VC") as? BrandCategoryTableViewController else {
                assertionFailure("[AssertionFailure] StoryBoard: BRANDCATEGORY_VC can't find!! (QRCodeViewController)")
                return
            }

            brandCategoryController.brandCategoryList = brandCategoryList
            brandCategoryController.menuList = self.menuInfos
            brandCategoryController.delegate = self
            //menuCreateController.delegate = self
            controller.setValue(brandCategoryController, forKey: "contentViewController")
            brandCategoryController.preferredContentSize.height = 350
            controller.preferredContentSize.height = 350
            controller.addChild(brandCategoryController)
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
                print("Cancel to delete brand category!")
            }

            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)

        }
        
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
           print("Cancel update")
        }
        cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
}

extension MenuListTableViewController: BrandCategoryDelegate {
    func deleteBrandCategoryComplete(sender: BrandCategoryTableViewController) {
        downloadFBMenuInformationList(select_index: self.selectedIndex)
    }
}
