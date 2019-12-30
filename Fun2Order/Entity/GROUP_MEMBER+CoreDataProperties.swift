//
//  GROUP_MEMBER+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/12/27.
//
//

import Foundation
import CoreData


extension GROUP_MEMBER {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GROUP_MEMBER> {
        return NSFetchRequest<GROUP_MEMBER>(entityName: "GROUP_MEMBER")
    }

    @NSManaged public var groupID: Int16
    @NSManaged public var memberID: String?
    @NSManaged public var memberName: String?
    @NSManaged public var memberImage: Data?

}
