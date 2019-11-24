//
//  PRODUCT_RECIPE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/23.
//
//

import Foundation
import CoreData


extension PRODUCT_RECIPE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PRODUCT_RECIPE> {
        return NSFetchRequest<PRODUCT_RECIPE>(entityName: "PRODUCT_RECIPE")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var productID: Int16
    @NSManaged public var recipe1: String?
    @NSManaged public var recipe2: String?
    @NSManaged public var recipe3: String?
    @NSManaged public var recipe4: String?
    @NSManaged public var recipe5: String?
    @NSManaged public var recipe6: String?
    @NSManaged public var recipe7: String?
    @NSManaged public var recipe8: String?
    @NSManaged public var recipe9: String?
    @NSManaged public var recipe10: String?
    @NSManaged public var storeID: Int16

}
