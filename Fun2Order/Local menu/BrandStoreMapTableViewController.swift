//
//  BrandStoreMapTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/22.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import Kingfisher

class BrandStoreMapTableViewController: UITableViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var brandBackgroundColor: UIColor!
    var brandTextTintColor: UIColor!
    var storeInfo: DetailStoreInformation = DetailStoreInformation()
    var detailMenuInfo: DetailMenuInformation = DetailMenuInformation()
    var menuOrder: MenuOrder = MenuOrder()
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D!
    var storeLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let friendNib: UINib = UINib(nibName: "BrandStoreCell", bundle: nil)
        self.tableView.register(friendNib, forCellReuseIdentifier: "BrandStoreCell")
        
        //self.tableView.backgroundColor = TEST_BACKGROUND_COLOR
        self.tableView.backgroundColor = self.brandBackgroundColor
        
        let app = UIApplication.shared.delegate as! AppDelegate
        self.locationManager = app.lm
        self.currentLocation = self.locationManager.location?.coordinate
        self.mapView.delegate = self
        setupMapView()
        displayAnnotation()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "分店地圖"
        self.navigationController?.title = "分店地圖"
        self.tabBarController?.title = "分店地圖"
    }

    func setupMapView() {
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
    }

    func displayAnnotation() {
        if self.storeInfo.storeAddress == nil {
            print("self.storeInfo.storeAddress is nil")
            return
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 11.0, *) {
           locationManager.showsBackgroundLocationIndicator = true
        } else {
           // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(self.storeInfo.storeAddress!, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }

            if placemarks != nil {
                for placemark in placemarks! {
                    self.storeLocation = placemark.location?.coordinate
                    
                    let storeAnnotation = MKPointAnnotation()
                    storeAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.storeLocation.latitude, longitude: self.storeLocation.longitude)
                    storeAnnotation.title = self.storeInfo.storeName
                    //storeAnnotation.subtitle = self.storeInfo.storeAddress
                    
                    self.mapView.addAnnotation(storeAnnotation)
                    let coordinateRegion = MKCoordinateRegion(center: self.storeLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    self.locationManager.stopUpdatingLocation()
                    break
                }
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        print("Display callout panel")
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        
        let imageView = UIImageView()
        let url = URL(string: self.storeInfo.storeImageURL!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

        imageView.kf.setImage(with: url) { result in
            switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                    annotationView?.leftCalloutAccessoryView = imageView
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
            }
        }
            
        let labelInformation = UILabel()
        labelInformation.numberOfLines = 2
        if (self.storeInfo.storePhoneNumber != nil) && (self.storeInfo.storeAddress != nil) {
            labelInformation.text = "電話: \(self.storeInfo.storePhoneNumber!)\n地址: \(self.storeInfo.storeAddress!)"
            annotationView!.detailCalloutAccessoryView = labelInformation
        }
        let button = UIButton(type: .detailDisclosure)
        button.tag = 100
        button.addTarget(self, action: #selector(displayRoute), for: .touchUpInside)
        annotationView?.rightCalloutAccessoryView = button
        
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    @objc func displayRoute(_ sender: UIButton) {
        print("Press button to display route")
        self.currentLocation = self.locationManager.location?.coordinate
        let fromPlaceMark = MKPlacemark(coordinate: self.currentLocation, addressDictionary: nil)
        let toPlaceMark = MKPlacemark(coordinate: self.storeLocation, addressDictionary: nil)
        let fromMapItem = MKMapItem(placemark: fromPlaceMark)
        let toMapItem = MKMapItem(placemark: toPlaceMark)
        
        fromMapItem.name = "現在地點"
        toMapItem.name = self.storeInfo.storeName
        
        let routes = [fromMapItem, toMapItem]
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem.openMaps(with: routes, launchOptions: options)
    }
    
    func createMenuOrder() {
        let timeZone = TimeZone.init(identifier: "UTC+8")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = DATETIME_FORMATTER
        
        let tmpOrderNumber = "M\(formatter.string(from: Date()))"

        self.menuOrder.orderNumber = tmpOrderNumber
        self.menuOrder.menuNumber = self.detailMenuInfo.menuNumber
        self.menuOrder.orderType = ORDER_TYPE_OFFICIAL_MENU
        self.menuOrder.orderStatus = ORDER_STATUS_READY
        self.menuOrder.orderOwnerID = Auth.auth().currentUser!.uid
        self.menuOrder.orderOwnerName = getMyUserName()
        self.menuOrder.orderTotalQuantity = 0
        self.menuOrder.orderTotalPrice = 0
        self.menuOrder.brandName = self.detailMenuInfo.brandName
        self.menuOrder.needContactInfoFlag = false

        var storeContact: StoreContactInformation = StoreContactInformation()
        storeContact.storeName = self.storeInfo.storeName
        storeContact.storeAddress = self.storeInfo.storeAddress
        storeContact.storePhoneNumber = self.storeInfo.storePhoneNumber
        storeContact.facebookURL = self.storeInfo.storeFacebookURL
        storeContact.instagramURL = self.storeInfo.storeInstagramURL

        self.menuOrder.storeInfo = storeContact
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = DATETIME_FORMATTER
        let timeString = timeFormatter.string(from: Date())
        self.menuOrder.createTime = timeString
        self.menuOrder.dueTime = ""

        var myContent: MenuOrderMemberContent = MenuOrderMemberContent()
        var myItem: MenuOrderContentItem = MenuOrderContentItem()

        myContent.memberID = Auth.auth().currentUser!.uid
        myContent.orderOwnerID = self.menuOrder.orderOwnerID
        myContent.memberTokenID = getMyTokenID()
        myItem.orderNumber = self.menuOrder.orderNumber
        myItem.itemOwnerID = Auth.auth().currentUser!.uid
        myItem.itemOwnerName = getMyUserName()
        myItem.replyStatus = MENU_ORDER_REPLY_STATUS_WAIT
        myItem.createTime = self.menuOrder.createTime
        myContent.orderContent = myItem
        myItem.ostype = "iOS"

        self.menuOrder.contentItems.append(myContent)
        self.uploadMenuOrder()
        self.sendMulticastNotification()
    }
    
    func uploadMenuOrder() {
        let databaseRef = Database.database().reference()
        
        if Auth.auth().currentUser?.uid == nil {
            print("uploadMenuOrder Auth.auth().currentUser?.uid == nil")
            return
        }
        
        let pathString = "USER_MENU_ORDER/\(Auth.auth().currentUser!.uid)/\(self.menuOrder.orderNumber)"
        databaseRef.child(pathString).setValue(self.menuOrder.toAnyObject()) { (error, reference) in
            if let error = error {
                print("uploadMenuOrder error = \(error.localizedDescription)")
                return
            } else {
                // Send notification to refresh HistoryList function
                print("GroupOrderViewController sends notification to refresh History List function")
                NotificationCenter.default.post(name: NSNotification.Name("RefreshHistory"), object: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let join_vc = storyboard.instantiateViewController(withIdentifier: "DETAIL_JOIN_ORDER_VC") as? DetailJoinGroupOrderTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (GroupOrderViewController)")
                    return
                }

                join_vc.detailMenuInformation = self.detailMenuInfo
                join_vc.memberContent = self.menuOrder.contentItems[0]
                join_vc.memberIndex = 0
                join_vc.menuOrder = self.menuOrder
                DispatchQueue.main.async {
                    self.show(join_vc, sender: self)
                }
            }
        }
    }

    func sendMulticastNotification() {
        var tokenIDs: [String] = [String]()
        
        if !self.menuOrder.contentItems.isEmpty {
            var orderNotify: NotificationData = NotificationData()
            let title: String = "團購邀請"
            var body: String = ""
            let dateNow = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = DATETIME_FORMATTER
            let dateTimeString = formatter.string(from: dateNow)

            body = "來自『 \(self.menuOrder.orderOwnerName)』 發起的團購邀請，請點擊通知以查看詳細資訊。"
            orderNotify.messageTitle = title
            orderNotify.messageBody = body
            orderNotify.notificationType = NOTIFICATION_TYPE_ACTION_JOIN_ORDER
            orderNotify.receiveTime = dateTimeString
            orderNotify.orderOwnerID = self.menuOrder.orderOwnerID
            orderNotify.orderOwnerName = self.menuOrder.orderOwnerName
            orderNotify.menuNumber = self.menuOrder.menuNumber
            orderNotify.orderNumber = self.menuOrder.orderNumber
            orderNotify.dueTime = self.menuOrder.dueTime
            orderNotify.brandName = self.menuOrder.brandName
            orderNotify.attendedMemberCount = self.menuOrder.contentItems.count
            orderNotify.messageDetail = ""
            orderNotify.isRead = "Y"

            // send to iOS type device
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.ostype != nil {
                    if self.menuOrder.contentItems[i].orderContent.ostype! == OS_TYPE_IOS {
                        tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                    }
                } else {
                    tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                }
            }
            
            if !tokenIDs.isEmpty {
                let sender = PushNotificationSender()
                sender.sendMulticastMessage(to: tokenIDs, notification_key: "", title: title, body: body, data: orderNotify, ostype: OS_TYPE_IOS)
            }
            
            tokenIDs.removeAll()
            // send to Android type device
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.ostype != nil {
                    if self.menuOrder.contentItems[i].orderContent.ostype! == OS_TYPE_ANDROID {
                        tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                    }
                }
            }
            
            if !tokenIDs.isEmpty {
                let sender = PushNotificationSender()
                usleep(100000)
                sender.sendMulticastMessage(to: tokenIDs, notification_key: "", title: title, body: body, data: orderNotify, ostype: OS_TYPE_ANDROID)
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BrandStoreCell", for: indexPath) as! BrandStoreCell
            
            cell.setData(store_info: self.storeInfo)
            //cell.backgroundColor = TEST_BACKGROUND_COLOR
            cell.backgroundColor = self.brandBackgroundColor
            cell.delegate = self
            cell.tag = indexPath.row

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
}

extension BrandStoreMapTableViewController: BrandStoreDelegate {
    func selectedStoreToOrder(sender: BrandStoreCell, index: Int) {
        print("Receive BrandStoreDelegate selectedStoreToOrder for index[\(index)]")
        downloadFBDetailMenuInformation(menu_number: self.storeInfo.storeMenuNumber, completion: { menu_info in
            if menu_info == nil {
                return
            }
            
            self.detailMenuInfo = menu_info!

            let controller = UIAlertController(title: "選擇訂購方式", message: nil, preferredStyle: .alert)
            
            let groupAction = UIAlertAction(title: "揪團訂購", style: .default) { (_) in
                print("Create GroupOrder for friends")
                guard let groupOrderController = self.storyboard?.instantiateViewController(withIdentifier: "DETAIL_CREATE_ORDER_VC") as? DetailGroupOrderTableViewController else {
                    assertionFailure("[AssertionFailure] StoryBoard: DETAIL_CREATE_ORDER_VC can't find!! (MenuListTableViewController)")
                    return
                }
                
                var storeContact: StoreContactInformation = StoreContactInformation()
                storeContact.storeName = self.storeInfo.storeName
                storeContact.storeAddress = self.storeInfo.storeAddress
                storeContact.storePhoneNumber = self.storeInfo.storePhoneNumber
                storeContact.facebookURL = self.storeInfo.storeFacebookURL
                storeContact.instagramURL = self.storeInfo.storeInstagramURL

                groupOrderController.orderType = ORDER_TYPE_OFFICIAL_MENU
                groupOrderController.brandName = self.detailMenuInfo.brandName
                groupOrderController.detailMenuInformation = self.detailMenuInfo
                groupOrderController.storeInfo = storeContact
                self.navigationController?.show(groupOrderController, sender: self)
            }
            
            groupAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(groupAction)
            
            let singleAction = UIAlertAction(title: "自己訂購", style: .default) { (_) in
                print("Create GroupOrder for myself")
                self.createMenuOrder()
            }
            
            singleAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(singleAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
               print("Cancel update")
            }
            
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
        })
    }
    
    func dialPhoneNumber(sender: BrandStoreCell, index: Int) {
        if self.storeInfo.storePhoneNumber == nil {
            print("Store Phone Number is nil")
            return
        }
            
        guard let url = URL(string: "tel://\(self.storeInfo.storePhoneNumber!)") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension BrandStoreMapTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

}
