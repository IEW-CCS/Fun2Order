//
//  MENU_RECIPE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/1/16.
//
//

import Foundation
import CoreData


extension MENU_RECIPE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MENU_RECIPE> {
        return NSFetchRequest<MENU_RECIPE>(entityName: "MENU_RECIPE")
    }

    @NSManaged public var menuNumber: String?
    @NSManaged public var recipeCategory: String?
    @NSManaged public var recipeName: String?
    @NSManaged public var sequenceNumber: Int16

}
