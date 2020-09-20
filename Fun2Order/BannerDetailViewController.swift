//
//  BannerDetailViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Firebase

class BannerDetailViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var buttonURL: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backView.layer.cornerRadius = 6
        
        setupAboutInfo()
        //testFunction()

    }

    @IBAction func openWebSite(_ sender: UIButton) {
        if let url = URL(string: "http://www.iew-pro.com") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func closeBanner(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func setData(image_name: UIImage, image_description: String) {
        self.bannerImage.image = image_name
        self.txtDescription.text = image_description
    }
    
    func setupAboutInfo() {
        let img = UIImage(named: "Fun2Order_AppStore_Icon.png")!
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let buildString = "Version: \(appVersion ?? "").\(build ?? "")"
        
        let aboutDescription = "歡迎使用 揪Fun\n\n\(buildString)\n\nTeamPlus@JStudio\n@2019-2020 Copyrignt Reserved"
        
        self.bannerImage.image = img
        self.txtDescription.text = aboutDescription
    }
    
    
    func testFunction() {
        //var brandCategory: DetailBrandCategory = DetailBrandCategory()
        var brandProfile: DetailBrandProfile = DetailBrandProfile()
        //var brandList: [DetailBrandCategory] = [DetailBrandCategory]()
        var brandList: [DetailBrandProfile] = [DetailBrandProfile]()
        
        let databaseRef = Database.database().reference()
        //let pathString = "VRAND_CATEGORY"
        let pathString = "DETAIL_BRAND_PROFILE"

        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let childEnumerator = snapshot.children
                
                let childDecoder: JSONDecoder = JSONDecoder()
                while let childData = childEnumerator.nextObject() as? DataSnapshot {
                    do {
                        let childJsonData = try? JSONSerialization.data(withJSONObject: childData.value as Any, options: [])
                        //let realData = try childDecoder.decode(DetailBrandCategory.self, from: childJsonData!)
                        let realData = try childDecoder.decode(DetailBrandProfile.self, from: childJsonData!)
                        brandList.append(realData)
                    } catch {
                        print("downloadFBBrandCategoryList jsonData decode failed: \(error.localizedDescription)")
                        continue
                    }
                }
                
                if brandList.isEmpty {
                    return
                }
                
                let storageRef = Storage.storage().reference()
                
                for i in 0...brandList.count - 1 {
                    let imagePath = brandList[i].brandIconImage
                    storageRef.child(imagePath!).downloadURL(completion: { (url, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        if url == nil {
                            print("downloadURL returns nil")
                            return
                        }
                        
                        print("downloadURL = \(url!)")
                        
                        //brandCategory = brandList[i]
                        //brandCategory.imageDownloadUrl = url?.absoluteString
                        //uploadFBBrandCategory(brand_name: brandCategory.brandName, brand_category: brandCategory)
                        
                        brandProfile = brandList[i]
                        brandProfile.imageDownloadUrl = url?.absoluteString
                        uploadFBDetailBrandProfile(brand_name: brandProfile.brandName, brand_profile: brandProfile)
                    })
                }
            }
        }) { (error) in
            print("testFunction: \(error.localizedDescription)")
        }
    }
}
