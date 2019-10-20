//
//  CommonStruct.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/15.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit

struct FavoriteStoreInfo {
    var storeName: String
    var storeAddressInfo: String
    var storeBrandImage: UIImage
    
    init() {
        self.storeName = ""
        self.storeAddressInfo = ""
        self.storeBrandImage = UIImage(named: "Fun2Order_AppStore_Icon.png")!
    }
    
    init(name: String, info: String, img: UIImage) {
        self.storeName = name
        self.storeAddressInfo = info
        self.storeBrandImage = img
    }
}
