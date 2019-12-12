//
//  FAVORITE_ADDRESS+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/12/10.
//
//

import Foundation
import CoreData


extension FAVORITE_ADDRESS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FAVORITE_ADDRESS> {
        return NSFetchRequest<FAVORITE_ADDRESS>(entityName: "FAVORITE_ADDRESS")
    }

    @NSManaged public var createTime: Date?
    @NSManaged public var favoriteAddress: String?

}
