//
//  BRAND_PROFILE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/23.
//
//

import Foundation
import CoreData


extension BRAND_PROFILE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BRAND_PROFILE> {
        return NSFetchRequest<BRAND_PROFILE>(entityName: "BRAND_PROFILE")
    }

    @NSManaged public var brandCategory: String?
    @NSManaged public var brandDescription: String?
    @NSManaged public var brandIconImage: Data?
    @NSManaged public var brandID: Int16
    @NSManaged public var brandName: String?
    @NSManaged public var brandSubCategory: String?
    @NSManaged public var brandUpdateDateTime: Date?

}
