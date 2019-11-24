//
//  CODE_TABLE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/23.
//
//

import Foundation
import CoreData


extension CODE_TABLE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CODE_TABLE> {
        return NSFetchRequest<CODE_TABLE>(entityName: "CODE_TABLE")
    }

    @NSManaged public var code: String?
    @NSManaged public var codeCategory: String?
    @NSManaged public var codeDescription: String?
    @NSManaged public var codeExtension: String?
    @NSManaged public var extension1: String?
    @NSManaged public var extension2: String?
    @NSManaged public var extension3: String?
    @NSManaged public var extension4: String?
    @NSManaged public var extension5: String?
    @NSManaged public var index: Int32
    @NSManaged public var subCode: String?
    @NSManaged public var subItem: String?

}
