//
//  FRIEND_TABLE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/2/23.
//
//

import Foundation
import CoreData


extension FRIEND_TABLE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FRIEND_TABLE> {
        return NSFetchRequest<FRIEND_TABLE>(entityName: "FRIEND_TABLE")
    }

    @NSManaged public var memberID: String?
    @NSManaged public var memberName: String?
    @NSManaged public var memberNickname: String?

}
