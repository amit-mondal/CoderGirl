//
//  Topic.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/12/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Topic: Object {
    dynamic var name: String = ""
    dynamic var desc: String = ""
    dynamic var progress: Double = 0
    func construct(aName: String, aDescription: String, oProgress: Double) {
        name = aName;
        desc = aDescription;
        progress = oProgress;
    }
    
}