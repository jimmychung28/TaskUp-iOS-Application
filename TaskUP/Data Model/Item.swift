//
//  Item.swift
//
//  Created by Jimmy Chung on 2019-04-20.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title:String=""
    @objc dynamic var done: Bool=false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var dateDeadline: Date?
    @objc dynamic var notificationID: String?
    @objc dynamic var order: Int=0
    var parentCategory=LinkingObjects(fromType: Category.self, property: "items")
}
