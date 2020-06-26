//
//  ORDER_INFORMATION+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/1/18.
//
//

import Foundation
import CoreData


extension ORDER_INFORMATION {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ORDER_INFORMATION> {
        return NSFetchRequest<ORDER_INFORMATION>(entityName: "ORDER_INFORMATION")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var brandName: String?
    @NSManaged public var deliveryAddress: String?
    @NSManaged public var deliveryType: String?
    @NSManaged public var orderCreateTime: Date?
    @NSManaged public var orderImage: Data?
    @NSManaged public var orderNumber: String?
    @NSManaged public var orderOwner: String?
    @NSManaged public var orderStatus: String?
    @NSManaged public var orderTotalPrice: Int16
    @NSManaged public var orderTotalQuantity: Int16
    @NSManaged public var orderType: String?
    @NSManaged public var storeID: Int16
    @NSManaged public var storeName: String?
    @NSManaged public var orderOwnerID: String?

}
