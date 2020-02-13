//
//  MENU_INFORMATION+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/2/4.
//
//

import Foundation
import CoreData


extension MENU_INFORMATION {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MENU_INFORMATION> {
        return NSFetchRequest<MENU_INFORMATION>(entityName: "MENU_INFORMATION")
    }

    @NSManaged public var brandCategory: String?
    @NSManaged public var brandName: String?
    @NSManaged public var createTime: String?
    @NSManaged public var menuDescription: String?
    @NSManaged public var menuImageURL: String?
    @NSManaged public var menuNumber: String?
    @NSManaged public var userID: String?
    @NSManaged public var userName: String?

}
