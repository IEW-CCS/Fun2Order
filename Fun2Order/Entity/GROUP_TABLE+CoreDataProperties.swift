//
//  GROUP_TABLE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/12/27.
//
//

import Foundation
import CoreData


extension GROUP_TABLE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GROUP_TABLE> {
        return NSFetchRequest<GROUP_TABLE>(entityName: "GROUP_TABLE")
    }

    @NSManaged public var groupID: Int16
    @NSManaged public var groupName: String?
    @NSManaged public var groupDescription: String?
    @NSManaged public var groupImage: Data?
    @NSManaged public var groupCreateTime: Date?

}
