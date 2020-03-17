//
//  BannerDetailViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class BannerDetailViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var txtDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backView.layer.cornerRadius = 6
        
        setupAboutInfo()
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
        
        let aboutDescription = "歡迎使用Fun2Order\n\n\(buildString)\n\nTeamPlus@JStudio\n@2019-2020 Copyrignt Reserved"
        
        self.bannerImage.image = img
        self.txtDescription.text = aboutDescription
    }
}
