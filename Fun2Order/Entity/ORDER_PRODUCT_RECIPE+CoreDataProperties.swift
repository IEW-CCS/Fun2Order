//
//  ORDER_PRODUCT_RECIPE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/12/1.
//
//

import Foundation
import CoreData


extension ORDER_PRODUCT_RECIPE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ORDER_PRODUCT_RECIPE> {
        return NSFetchRequest<ORDER_PRODUCT_RECIPE>(entityName: "ORDER_PRODUCT_RECIPE")
    }

    @NSManaged public var orderNumber: String?
    @NSManaged public var productID: Int16
    @NSManaged public var recipeCode: String?
    @NSManaged public var recipeSubCode: String?
    @NSManaged public var itemNumber: Int16

}
