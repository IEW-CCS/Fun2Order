//
//  BrandStoreCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Kingfisher
import MapKit

protocol BrandStoreDelegate: class {
    func selectedStoreToOrder(sender: BrandStoreCell, index: Int)
    func displayStoreMap(sender: BrandStoreCell, index: Int)
    func dialPhoneNumber(sender: BrandStoreCell, index: Int)
}

extension BrandStoreDelegate {
    func selectedStoreToOrder(sender: BrandStoreCell, index: Int) {}
    func displayStoreMap(sender: BrandStoreCell, index: Int) {}
    func dialPhoneNumber(sender: BrandStoreCell, index: Int) {}
}

class BrandStoreCell: UITableViewCell {
    @IBOutlet weak var imageStore: UIImageView!
    @IBOutlet weak var labelStoreName: UILabel!
    @IBOutlet weak var labelStorePhoneNumber: UILabel!
    @IBOutlet weak var labelStoreAddress: UILabel!
    @IBOutlet weak var buttonOrder: UIButton!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var imageMap: UIImageView!
    @IBOutlet weak var labelBusinessTime: UILabel!
    
    var storeInfo: DetailStoreInformation = DetailStoreInformation()
    weak var delegate: BrandStoreDelegate?
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D!
    var storeLocation: CLLocationCoordinate2D!
    var openTime: String = ""
    var closeTime: String = ""
    var offFlag: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageStore.layer.borderWidth = CGFloat(1.0)
        self.imageStore.layer.borderColor = UIColor.clear.cgColor
        self.imageStore.layer.cornerRadius = 6
        
        self.buttonOrder.layer.borderWidth = CGFloat(1.0)
        self.buttonOrder.layer.borderColor = UIColor.clear.cgColor
        self.buttonOrder.layer.cornerRadius = 6
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handlePhoneNumberTap(_:)))
        self.labelStorePhoneNumber.addGestureRecognizer(tapGesture)
        self.labelStorePhoneNumber.isUserInteractionEnabled = true
        
        self.imageMap.isHidden = false
        let storeImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleMapTap))
        self.imageStore.addGestureRecognizer(storeImageTapGesture)
        self.imageStore.isUserInteractionEnabled = true
        
        let mapImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleMapTap))
        self.imageMap.addGestureRecognizer(mapImageTapGesture)
        self.imageMap.isUserInteractionEnabled = true
                
    }

    @objc func handlePhoneNumberTap(_ sender: UITapGestureRecognizer) {
        print("Tap the phone number")
        self.delegate?.dialPhoneNumber(sender: self, index: self.tag)
    }
    
    @objc func handleMapTap(_ sender: UITapGestureRecognizer) {
        print("Tap to display Store Map function")
        self.delegate?.displayStoreMap(sender: self, index: self.tag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(store_info: DetailStoreInformation) {
        self.storeInfo = store_info
        
        if store_info.storeImageURL != nil {
            //print("store_info.storeImageURL is not nil")
            //print("store_info.storeImageURLL = \(store_info.storeImageURL!)")
            let url = URL(string: store_info.storeImageURL!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            //print("url = \(String(describing: url))")
            self.imageStore.kf.setImage(with: url)
        }
        
        self.labelStoreName.text = store_info.storeName
        self.labelStoreAddress.text = store_info.storeAddress
        self.labelStorePhoneNumber.text = store_info.storePhoneNumber
        calculateDistance()
        setupBusinessTime()
    }
    
    func calculateDistance() {
        let app = UIApplication.shared.delegate as! AppDelegate
        self.locationManager = app.lm
        self.currentLocation = self.locationManager.location?.coordinate

        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(self.storeInfo.storeAddress!, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }

            if placemarks != nil {
                for placemark in placemarks! {
                    self.storeLocation = placemark.location?.coordinate
                    let loc1 = CLLocation(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude)
                    let loc2 = CLLocation(latitude: self.storeLocation.latitude, longitude: self.storeLocation.longitude)
                    
                    let distanceM = loc1.distance(from: loc2)
                    print("[\(self.storeInfo.storeName)] distance from current location is: \(distanceM) m")
                    
                    if distanceM < 1000 {
                        self.labelDistance.text = String(Int(distanceM)) + " 公尺"
                    } else {
                        let distanceKM = distanceM / 1000
                        print("KM = \(String(format:"%.1f KM", arguments:[distanceKM]))")
                        self.labelDistance.text = String(format:"%.1f 公里", arguments:[distanceKM])
                    }
                    break
                }
            }
        })
    }
    
    func setupBusinessTime() {
        downloadFBStoreBusinessTimeChange(brand_name: self.storeInfo.brandName, store_name: self.storeInfo.storeName, completion: { businessData in
            if businessData != nil {
                if businessData!.dayOffFlag {
                    self.labelBusinessTime.text = "今日店休"
                    self.offFlag = true
                    return
                } else {
                    if self.storeInfo.businessTime != nil {
                        self.storeInfo.businessTime?.openTime = businessData!.openTime
                        self.storeInfo.businessTime?.closeTime = businessData!.closeTime
                        self.openTime = businessData!.openTime
                        self.closeTime = businessData!.closeTime
                        self.labelBusinessTime.text = "今日營業時間：\(self.openTime)至\(self.closeTime)"
                    }
                }
            } else {
                guard let openTimeString = self.storeInfo.businessTime?.openTime else {
                    print("Get Store Open Time failed")
                    //presentSimpleAlertMessage(title: "錯誤訊息", message: "店家未定義營業時間，請聯絡系統管理員")
                    return
                }
                
                guard let closeTimeString = self.storeInfo.businessTime?.closeTime else {
                    print("Get Store Close Time failed")
                    //presentSimpleAlertMessage(title: "錯誤訊息", message: "店家未定義營業時間，請聯絡系統管理員")
                    return
                }
                
                self.openTime = openTimeString
                self.closeTime = closeTimeString
                self.labelBusinessTime.text = "今日營業時間：\(self.openTime)至\(self.closeTime)"
            }
        })
    }
    
    @IBAction func createOrder(_ sender: UIButton) {
        if self.offFlag {
            presentSimpleAlertMessage(title: "提示訊息", message: "今日店家公休，請擇日再試")
            return
        }
        
        if self.openTime == "" || self.closeTime == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "店家未定義營業時間，請聯絡系統管理員")
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: Date())
            
        if timeString < self.openTime {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "目前還未到店家營業時間，請稍候再試")
            return
        }
        
        if timeString > self.closeTime {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "目前已過店家營業時間，請於明日再試")
            return
        }

        self.delegate?.selectedStoreToOrder(sender: self, index: self.tag)
    }
}
