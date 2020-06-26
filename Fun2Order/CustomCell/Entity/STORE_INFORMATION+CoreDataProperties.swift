//
//  STORE_INFORMATION+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/23.
//
//

import Foundation
import CoreData


extension STORE_INFORMATION {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STORE_INFORMATION> {
        return NSFetchRequest<STORE_INFORMATION>(entityName: "STORE_INFORMATION")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var deliveryService: String?
    @NSManaged public var storeAddress: String?
    @NSManaged public var storeCategory: String?
    @NSManaged public var storeDescription: String?
    @NSManaged public var storeID: Int16
    @NSManaged public var storeName: String?
    @NSManaged public var storePhoneNumber: String?
    @NSManaged public var storeSubCategory: String?

}
