//
//  MENU_ITEM+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/1/16.
//
//

import Foundation
import CoreData


extension MENU_ITEM {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MENU_ITEM> {
        return NSFetchRequest<MENU_ITEM>(entityName: "MENU_ITEM")
    }

    @NSManaged public var itemName: String?
    @NSManaged public var itemPrice: Int16
    @NSManaged public var menuNumber: String?
    @NSManaged public var sequenceNumber: Int16

}
