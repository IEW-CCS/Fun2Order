//
//  FavoriteTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class FavoriteTableViewController: UITableViewController {
    let brandTitles: [String] = ["上宇林", "丸作", "五十嵐", "公館手作", "迷克夏", "自在軒", "柚豆", "紅太陽", "茶湯會", "圓石", "Teas原味"]

    var favoriteStoreArray = [FavoriteStoreInfo]()
    var isSelectStoreCellOpened: Bool = false
    var brandProfileList: BrandProfile!

    @IBOutlet weak var menuBarItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.title = self.title

        let cellViewNib: UINib = UINib(nibName: "SelectStoreCell", bundle: nil)
        self.tableView.register(cellViewNib, forCellReuseIdentifier: "SelectStoreCell")

        let favoriteCellViewNib: UINib = UINib(nibName: "FavoriteStoreCell", bundle: nil)
        self.tableView.register(favoriteCellViewNib, forCellReuseIdentifier: "FavoriteStoreCell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveBrandInfo(_:)),
            name: NSNotification.Name(rawValue: "BrandInfo"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addToFavorite(_:)),
            name: NSNotification.Name(rawValue: "AddToFavorite"),
            object: nil
        )

        requestBrandProfileList()
    }

    func requestBrandProfileList() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let temp = getFirebaseUrlForRequest(uri: "BrandProfile/五十嵐")
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestBrandProfileList")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil{
                    DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let httpAlert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(httpAlert, animated : false, completion : nil)
                }
                else{
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let httpAlert = alert(message: message, title: "Http Error")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                    }
                    
                    DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.brandProfileList = try decoder.decode(BrandProfile.self, from: jsonData!)
                    //if !self.brandProfileList.isEmpty {
                    //    self.updateBrandProfileToCoreData()
                    //}
              }
            } catch {
                print(error.localizedDescription)
                let httpalert = alert(message: error.localizedDescription, title: "Request BrandProfile Error")
                self.present(httpalert, animated : false, completion : nil)
                return
            }
        }
        task.resume()
        
        return
    }

    func updateBrandProfileToCoreData() {
        
    }
    
    @objc func receiveBrandInfo(_ notification: Notification) {
        if let brandIndex = notification.object as? Int {
            print("FavoriteTableViewController received brand name: \(self.brandTitles[brandIndex])")
            self.tabBarController?.title = self.brandTitles[brandIndex]
        }
    }
    
    @objc func addToFavorite(_ notification: Notification) {
        if let storeInfo = notification.object as? FavoriteStoreInfo {
            print("FavoriteTableViewController received store name: \(storeInfo.storeName)")
            print("FavoriteTableViewController received store addr: \(storeInfo.storeAddressInfo)")
            self.favoriteStoreArray.append(storeInfo)
            print("self.favoriteStoreArray.count = \(self.favoriteStoreArray.count)")
            let indexPath = IndexPath(row: self.favoriteStoreArray.count - 1 , section: 1)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.isSelectStoreCellOpened {
                return 1
            } else {
                return 0
            }
        } else {
            if self.favoriteStoreArray.isEmpty {
                return 0
            }
        
            return self.favoriteStoreArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectStoreCell", for: indexPath) as! SelectStoreCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteStoreCell", for: indexPath) as! FavoriteStoreCell
        cell.setData(brand_image: self.favoriteStoreArray[indexPath.row].storeBrandImage,
                     title: self.favoriteStoreArray[indexPath.row].storeName,
                     sub_title: self.favoriteStoreArray[indexPath.row].storeAddressInfo)

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        cell.indexPath = indexPath

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if editingStyle == .delete {
                self.favoriteStoreArray.remove(at: indexPath.row )
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else {
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let sectionView = UIView(frame: CGRect(x: 5, y: 0, width: tableView.frame.width - 10, height: 44))
            sectionView.layer.borderWidth = 1
            sectionView.layer.borderColor = UIColor.darkGray.cgColor
            sectionView.backgroundColor = UIColor(red: 179/255, green: 229/255, blue: 252/255, alpha: 1.0)
            //let sectionTitle = UILabel(frame: sectionView.layer.frame)
            let sectionTitle = UILabel(frame: CGRect(x: 5, y: 0, width: tableView.frame.width - 10, height: 44))
            sectionTitle.text = "Select Store"
            sectionTitle.textAlignment = .center
            sectionView.addSubview(sectionTitle)
            
            let tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(self.headerTapped(_:))
            )
            sectionView.addGestureRecognizer(tapGestureRecognizer)
            return sectionView
        }
        
        return tableView.headerView(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 230
        }
        
        return 100
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "ProductList_VC") as? ProductDetailTableViewController else{
                assertionFailure("[AssertionFailure] StoryBoard: pickerStoryboard can't find!! (ViewController)")
                return
            }
            show(vc, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0
        } else {
            return 44
        }
    }

    @objc func headerTapped(_ sender: UITapGestureRecognizer?) {
        print("Section Header tapped")
        if self.isSelectStoreCellOpened {
            self.isSelectStoreCellOpened = false
            let sections = IndexSet.init(integer: 0)
            tableView.reloadSections(sections, with: .fade)
        } else {
            self.isSelectStoreCellOpened = true
            let sections = IndexSet.init(integer: 0)
            tableView.reloadSections(sections, with: .fade)
        }
    }
    
}

extension FavoriteTableViewController: DisplayGroupOrderDelegate {
    func didGroupButtonPressed(at index: IndexPath) {
        guard let groupOrderController = self.storyboard?.instantiateViewController(withIdentifier: "GroupOrder_VC") as? GroupOrderViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (QRCodeViewController)")
            return
        }
        
        groupOrderController.modalTransitionStyle = .crossDissolve
        groupOrderController.modalPresentationStyle = .overFullScreen
        navigationController?.present(groupOrderController, animated: true, completion: nil)
    }
}
