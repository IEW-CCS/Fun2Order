//
//  PRODUCT_INFORMATION+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/23.
//
//

import Foundation
import CoreData


extension PRODUCT_INFORMATION {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PRODUCT_INFORMATION> {
        return NSFetchRequest<PRODUCT_INFORMATION>(entityName: "PRODUCT_INFORMATION")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var limit: String?
    @NSManaged public var popularity: String?
    @NSManaged public var productCategory: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var productID: Int16
    @NSManaged public var productImage: Data?
    @NSManaged public var productName: String?
    @NSManaged public var recommand: String?

}
