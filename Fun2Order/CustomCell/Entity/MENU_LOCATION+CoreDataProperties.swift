//
//  MENU_LOCATION+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/1/9.
//
//

import Foundation
import CoreData


extension MENU_LOCATION {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MENU_LOCATION> {
        return NSFetchRequest<MENU_LOCATION>(entityName: "MENU_LOCATION")
    }

    @NSManaged public var menuNumber: String?
    @NSManaged public var locationName: String?

}
