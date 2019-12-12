//
//  ORDER_CONTENT_ITEM+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/12/3.
//
//

import Foundation
import CoreData


extension ORDER_CONTENT_ITEM {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ORDER_CONTENT_ITEM> {
        return NSFetchRequest<ORDER_CONTENT_ITEM>(entityName: "ORDER_CONTENT_ITEM")
    }

    @NSManaged public var orderNumber: String?
    @NSManaged public var productID: Int16
    @NSManaged public var productName: String?
    @NSManaged public var itemOwnerName: String?
    @NSManaged public var itemOwnerImage: Data?
    @NSManaged public var itemCreateTime: Date?
    @NSManaged public var itemQuantity: Int16
    @NSManaged public var itemSinglePrice: Int16
    @NSManaged public var itemFinalPrice: Int16
    @NSManaged public var itemComments: String?
    @NSManaged public var itemNumber: Int16

}
