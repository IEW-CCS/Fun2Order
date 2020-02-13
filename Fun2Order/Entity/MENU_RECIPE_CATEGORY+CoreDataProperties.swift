//
//  MENU_RECIPE_CATEGORY+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/1/16.
//
//

import Foundation
import CoreData


extension MENU_RECIPE_CATEGORY {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MENU_RECIPE_CATEGORY> {
        return NSFetchRequest<MENU_RECIPE_CATEGORY>(entityName: "MENU_RECIPE_CATEGORY")
    }

    @NSManaged public var isAllowedMulti: Bool
    @NSManaged public var menuNumber: String?
    @NSManaged public var recipeCategory: String?
    @NSManaged public var sequenceNumber: Int16

}
