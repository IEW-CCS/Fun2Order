//
//  MENU_ICON+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/2/4.
//
//

import Foundation
import CoreData


extension MENU_ICON {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MENU_ICON> {
        return NSFetchRequest<MENU_ICON>(entityName: "MENU_ICON")
    }

    @NSManaged public var menuNumber: String?
    @NSManaged public var menuIcon: Data?

}
