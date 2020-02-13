//
//  MENU_RECIPE_TEMPLATE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/1/9.
//
//

import Foundation
import CoreData


extension MENU_RECIPE_TEMPLATE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MENU_RECIPE_TEMPLATE> {
        return NSFetchRequest<MENU_RECIPE_TEMPLATE>(entityName: "MENU_RECIPE_TEMPLATE")
    }

    @NSManaged public var templateName: String?
    @NSManaged public var recipeCategory: String?
    @NSManaged public var recipeName: String?

}
