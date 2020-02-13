//
//  MENU_BRAND_CATEGORY+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/1/12.
//
//

import Foundation
import CoreData


extension MENU_BRAND_CATEGORY {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MENU_BRAND_CATEGORY> {
        return NSFetchRequest<MENU_BRAND_CATEGORY>(entityName: "MENU_BRAND_CATEGORY")
    }

    @NSManaged public var categoryName: String?

}
