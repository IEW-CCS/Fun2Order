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
    var groupOrderFlag: Bool = false

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

        imageView.kf.setImage(with: url, completionHandler:  { result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
                annotationView?.leftCalloutAccessoryView = imageView
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        })

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
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let annotation = views.first(where: { $0.reuseIdentifier == "Pin" })?.annotation {
            mapView.selectAnnotation(annotation, animated: true)
        }
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

            var storeContact: StoreContactInformation = StoreContactInformation()
            storeContact.storeName = self.storeInfo.storeName
            storeContact.storeAddress = self.storeInfo.storeAddress
            storeContact.storePhoneNumber = self.storeInfo.storePhoneNumber
            storeContact.facebookURL = self.storeInfo.storeFacebookURL
            storeContact.instagramURL = self.storeInfo.storeInstagramURL

            guard let deliveryController = self.storyboard?.instantiateViewController(withIdentifier: "DELIVERY_INFO_VC") as? DeliveryInformationTableViewController else {
                assertionFailure("[AssertionFailure] StoryBoard: DELIVERY_INFO_VC can't find!! (BrandStoreListTableViewController)")
                return
            }

            deliveryController.orderType = ORDER_TYPE_OFFICIAL_MENU
            deliveryController.brandName = self.detailMenuInfo.brandName
            deliveryController.storeName = self.storeInfo.storeName
            deliveryController.detailMenuInformation = self.detailMenuInfo
            deliveryController.storeInfo = storeContact
            deliveryController.brandBackgroundColor = self.brandBackgroundColor
            deliveryController.brandTextTintColor = self.brandTextTintColor

            let controller = UIAlertController(title: "選擇訂購方式", message: nil, preferredStyle: .alert)
            
            let groupAction = UIAlertAction(title: "揪團訂購", style: .default) { (_) in
                print("Create GroupOrder for friends")
                self.groupOrderFlag = true
                
                deliveryController.groupOrderFlag = self.groupOrderFlag
                self.navigationController?.show(deliveryController, sender: self)
            }
            
            groupAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(groupAction)
            
            let singleAction = UIAlertAction(title: "自己訂購", style: .default) { (_) in
                print("Create GroupOrder for myself")
                self.groupOrderFlag = false
                
                deliveryController.groupOrderFlag = self.groupOrderFlag
                self.navigationController?.show(deliveryController, sender: self)
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
