//
//  NOTIFICATION_TABLE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2020/1/30.
//
//

import Foundation
import CoreData


extension NOTIFICATION_TABLE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NOTIFICATION_TABLE> {
        return NSFetchRequest<NOTIFICATION_TABLE>(entityName: "NOTIFICATION_TABLE")
    }

    @NSManaged public var receiveTime: Date?
    @NSManaged public var messageTitle: String?
    @NSManaged public var messageBody: String?
    @NSManaged public var messageID: String?
    @NSManaged public var notificationData: String?
    @NSManaged public var isRead: Bool

}
