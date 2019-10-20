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

        // Do any additional setup after loading the view.
    }

    @IBAction func closeBanner(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func setData(image_name: UIImage, image_description: String) {
        self.bannerImage.image = image_name
        self.txtDescription.text = image_description
    }
}
