//
//  CustomizedControle.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit


class IgnoreTouchView : UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

class NoSwipeSegmentedControl: UISegmentedControl {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer.isKind(of: UITapGestureRecognizer.self)){
            return false
        } else {
            return true 
        }
    }
}
