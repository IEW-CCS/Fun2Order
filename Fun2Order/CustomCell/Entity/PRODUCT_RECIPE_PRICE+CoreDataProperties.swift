//
//  PRODUCT_RECIPE_PRICE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/23.
//
//

import Foundation
import CoreData


extension PRODUCT_RECIPE_PRICE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PRODUCT_RECIPE_PRICE> {
        return NSFetchRequest<PRODUCT_RECIPE_PRICE>(entityName: "PRODUCT_RECIPE_PRICE")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var price: Int16
    @NSManaged public var productID: Int16
    @NSManaged public var recipeCode: String?
    @NSManaged public var recipeSubCode: String?
    @NSManaged public var storeID: Int16

}
