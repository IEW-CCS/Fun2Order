//
//  BrandStruct.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/11.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit

struct NewBrandProfile: Codable {
    var brandID: Int = 0
    var brandName: String = ""
    var brandIconImage: String?
    var brandCategory: String?
    var brandSubCategory: String?
    var brandDescription: String?
    var brandWebURL: String?
    var brandUpdateDateTime: String = ""
}

struct DetailProductItem: Codable {
    var productName: String = ""
    var productCategory: String?
    var productDescription: String?
    var productImageURL: String?
    var productPrice: Int = 0
    var recipeTemplates: [String]?
}

struct ActivityAttendMember: Codable {
    var memberID: String = ""
    var memberToken: String = ""
    var memberName: String = ""
    var replyStatus: String = ""
    var replyDateTime: String = ""
    var estimateCost: Int = 0
    var activityTimeSlot: ActivityTimeSlot?
    var activityAttendTypes: [ActivityAttendType]?
}

struct ActivityAttendType: Codable {
    var typeName: String = ""
    var typeCount: Int = 0
    var typeDescription: String?
    var typeCost: Int = 0
}

struct ActivityTimeSlot: Codable {
    var fromTime: String = ""
    var toTime: String = ""
    var countLimit: Int = 0
    //var attendMembers: [ActivityAttendMember]?
}

struct ActivityInformation: Codable {
    var avtivityID: String = ""
    var activityDescription: String?
    var avtivityImages: [String]?
    var avtivityLocation: String = ""
    var activityMapAddress: String?
    var avtivityDateTime: String = ""
    var activityTrafficType: String?
    var attendCountLimit: Int = 0
    var activityTimeSlot: [ActivityTimeSlot]?
    var activityAttendTypes: [ActivityAttendType]?
}

struct ActivityEvent: Codable {
    var eventID: String = ""
    var activityInfoID: String = ""
    var attendMembers: [ActivityAttendMember]?
}
