//
//  FAVORITE_STORE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/24.
//
//

import Foundation
import CoreData


extension FAVORITE_STORE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FAVORITE_STORE> {
        return NSFetchRequest<FAVORITE_STORE>(entityName: "FAVORITE_STORE")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var insertDateTime: Date?
    @NSManaged public var storeBrandImage: Data?
    @NSManaged public var storeDescription: String?
    @NSManaged public var storeID: Int16
    @NSManaged public var storeName: String?
    @NSManaged public var brandName: String?

}
