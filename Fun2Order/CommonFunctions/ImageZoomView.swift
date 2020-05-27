//
//  ImageZoomView.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/25.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit

class ImageZoomView: UIScrollView, UIScrollViewDelegate {
    var imageView: UIImageView!
    var gestureRecognizer: UITapGestureRecognizer!
    
    convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        backgroundColor = UIColor.black

        setupScrollView()

        self.imageView = UIImageView(frame: frame)
        //imageView = UIImageView(image: image)
        //imageView.frame = frame
        self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        //imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        self.imageView.image = image
        addSubview(self.imageView)
        
        self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        //setupGestureRecognizer()
    }
    
    func setupScrollView() {
        minimumZoomScale = 0.6
        maximumZoomScale = 2.5
        delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    // Sets up the gesture recognizer that receives double taps to auto-zoom
    func setupGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(gestureRecognizer)
    }
    
    // Handles a double tap by either resetting the zoom or zooming to where was tapped
    @objc func handleDoubleTap() {
        if zoomScale == 1 {
            zoom(to: zoomRectForScale(maximumZoomScale, center: gestureRecognizer.location(in: gestureRecognizer.view)), animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
    // Calculates the zoom rectangle for the scale
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = self.imageView.frame.size.height / scale
        zoomRect.size.width = self.imageView.frame.size.width / scale
        let newCenter = convert(center, from: self.imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
}
