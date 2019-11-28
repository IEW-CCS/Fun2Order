//
//  ShadowGradientView.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/19.
//  Copyright © 2019 JStudio. All rights reserved.
//
import UIKit
import Foundation

@IBDesignable class ShadowGradientView: UIView {
    private var didSetupConstraints = false
    private var gradientLayer: CAGradientLayer!
    private var label: UILabel!
    
    // Set default gradient color to be Green
    @IBInspectable var gradientColor: Int = 4 {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var gradientBorderColor: UIColor = .clear {
        didSet {
            updateGradient()
        }
    }

    @IBInspectable var gradientBorderWidth: Int = 1 {
        didSet {
            updateGradient()
        }
    }

    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            updateShadow()
        }
    }
    
    @IBInspectable var shadowBlur: CGFloat = 4 {
        didSet {
            updateShadow()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = CELL_CORNER_RADIUS {
        didSet {
            updateShadow()
        }
    }
    
    @IBInspectable var labelText: String = "" {
        didSet {
            updateLabel()
        }
    }
    
    @IBInspectable var labelColor: UIColor = .black {
        didSet {
            updateLabel()
        }
    }
    
    @IBInspectable var labelFontSize: Int = 17 {
        didSet {
            updateLabel()
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        installShadow()
        installGradient()
        installLabel()
        updateShadow()
        updateGradient()
        updateLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installShadow()
        installGradient()
        installLabel()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        installShadow()
        installGradient()
        installLabel()
    }
    
    public func AdjustAutoLayout()
    {
        installShadow()
    
        let ori = self.gradientLayer.frame
        self.gradientLayer.frame = ori.AdjustCAGradientLayer(width: self.layer.frame.width-10)
        self.label.frame = self.gradientLayer.frame
        self.label.textAlignment = .center
        self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        print("ori.width: \(ori.width), self.layer.frame.width: \(self.layer.frame.width)")
        //updateShadow()
    }

    private func installShadow() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.zPosition = -1
        
        if shadowBlur >= 0 {
            self.layer.shadowOpacity = 0.3
            self.layer.shadowRadius = shadowBlur
            self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: cornerRadius).cgPath
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    private func installGradient() {
        self.gradientLayer = createGradient()
        self.gradientLayer.colors = GRADIENT_COLOR_SET[gradientColor]
        self.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        self.gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.45)
        self.gradientLayer.cornerRadius = cornerRadius
        self.gradientLayer.zPosition = 1
        self.layer.addSublayer(gradientLayer)
    }
    
    private func installLabel() {
        self.label = createLabel()
        self.label.layer.zPosition = 9
        self.addSubview(self.label)
        self.label.textAlignment = .center
        self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    private func updateGradient() {
        self.gradientLayer.colors = GRADIENT_COLOR_SET[gradientColor]
        self.gradientLayer.borderWidth = CGFloat(gradientBorderWidth)
        self.gradientLayer.borderColor = gradientBorderColor.cgColor
    }
    
    private func updateShadow() {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        
        if shadowBlur >= 0 {
            self.layer.shadowRadius = shadowBlur
            self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: cornerRadius).cgPath
        }
    }
    
    private func updateLabel() {
        self.label.text = labelText
        self.label.textColor = labelColor
    }
    
    private func createGradient() -> CAGradientLayer{
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds.insetBy(dx: SHADOW_INNERVIEW_INSET, dy: SHADOW_INNERVIEW_INSET)
        return gradient
    }
    
    private func createLabel() -> UILabel {
        let lbl = UILabel(frame: self.bounds.insetBy(dx: SHADOW_INNERVIEW_INSET, dy: SHADOW_INNERVIEW_INSET))
        lbl.textAlignment = .center
        
        return lbl
    }
    

    func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
        let fromColors = self.gradientLayer?.colors
        let toColors: [AnyObject] = [ newTopColor.cgColor, newBottomColor.cgColor]
        self.gradientLayer?.colors = toColors
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        self.gradientLayer?.add(animation, forKey:"animateGradient")
    }
}

extension CGRect {
    func AdjustCAGradientLayer( width : CGFloat) -> CGRect {
        let x = self.origin.x
        let y = self.origin.y
        //let w = self.width
        let h = self.height
        
        let newW = width
        let newH = h
        let newX = x
        let newY = y
        
        return CGRect(x: newX, y: newY, width: newW, height: newH)
    }
}
