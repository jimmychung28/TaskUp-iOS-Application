//
//  Category.swift
//
//  Created by Jimmy Chung on 2019-04-20.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name:String=""
    let items = List<Item>()
    @objc dynamic var backgroundColor:String=""
    @objc dynamic var order: Int=0
}
