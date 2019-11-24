//
//  STORE_BUSINESS_HOURS+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/23.
//
//

import Foundation
import CoreData


extension STORE_BUSINESS_HOURS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STORE_BUSINESS_HOURS> {
        return NSFetchRequest<STORE_BUSINESS_HOURS>(entityName: "STORE_BUSINESS_HOURS")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var friday: String?
    @NSManaged public var monday: String?
    @NSManaged public var saturday: String?
    @NSManaged public var storeID: Int16
    @NSManaged public var sunday: String?
    @NSManaged public var thursday: String?
    @NSManaged public var tuesday: String?
    @NSManaged public var wednesday: String?

}
