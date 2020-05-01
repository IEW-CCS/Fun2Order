//
//  ToolTipDelegate.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/28.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit

protocol GuideToolTipDelegate: class {
    func triggerCreateMenuTooltip(parent: UIView)
    func triggerMyProfileToolTip(parent: UIView)
    func triggerMyFriendToolTip(parent: UIView)
    func triggerMyGroupToolTip(parent: UIView)
    func triggerGroupOrderToolTip(parent: UIView)
}

extension GuideToolTipDelegate {
    func triggerCreateMenuTooltip(parent: UIView) {}
    func triggerMyProfileToolTip(parent: UIView) {}
    func triggerMyFriendToolTip(parent: UIView) {}
    func triggerMyGroupToolTip(parent: UIView) {}
    func triggerGroupOrderToolTip(parent: UIView) {}
}
