//
//  FAVORITE_PRODUCT+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/30.
//
//

import Foundation
import CoreData


extension FAVORITE_PRODUCT {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FAVORITE_PRODUCT> {
        return NSFetchRequest<FAVORITE_PRODUCT>(entityName: "FAVORITE_PRODUCT")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var productID: Int16
    @NSManaged public var storeID: Int16

}
