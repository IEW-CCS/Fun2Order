//
//  QRCodeViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var qrCodeLabel: UILabel!
    var qrCodeText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.backView.layer.borderWidth = CGFloat(1.5)
        self.backView.layer.borderColor = UIColor.black.cgColor
        self.backView.layer.cornerRadius = 10
        
        let gesTap = UITapGestureRecognizer(target: self, action:#selector(self.handleTapGesture(_:)))
        gesTap.delegate = self
        self.view.addGestureRecognizer(gesTap)

        setQRCodeImage()
    }
    
    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    func setQRCodeText(code: String) {
        self.qrCodeText = code
    }
    
    
    private func setQRCodeImage() {
        var qrImage: CIImage!
        
        let data = self.qrCodeText.data(using: .utf8, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        qrImage = filter?.outputImage
        
        let scaleX = 200 / qrImage.extent.size.width
        let scaleY = 200 / qrImage.extent.size.height
        let transformedImage = qrImage.transformed(by: CGAffineTransform(scaleX: CGFloat(scaleX), y: CGFloat(scaleY)))
        
        
        self.qrCodeLabel.text = self.qrCodeText
        self.qrCodeImage.image = UIImage(ciImage: transformedImage)
    }

}
