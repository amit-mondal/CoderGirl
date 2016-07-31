//
//  Command.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/14/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Command: Object {
    dynamic var type: String = ""
    dynamic var value: String = ""
    dynamic var queryValue: String = ""
    dynamic var response: String = ""
    dynamic var left: Command? = nil
    dynamic var right: Command? = nil
    
    func construct(aType: String, sInput: String) {
        type = aType.lowercaseString
        if (aType.lowercaseString == "ask") {
            queryValue = sInput
        }
        else {
            value = sInput
        }

    }
    
    func construct(aType: String, aValue: String, aLeft: Command?) {
        type = aType.lowercaseString
        value = aValue
        left = aLeft
    }
    func construct(aType: String) {
        type = aType.lowercaseString
    }
    
    func evalEquals() -> Character {
        if let left = left {
            if left.response.lowercaseString == value.lowercaseString {
                print("\(left.response.lowercaseString) == \(value.lowercaseString) - t")
                return "t"
            }
            else {
                print("\(left.response.lowercaseString) == \(value.lowercaseString) - f")
                return "f"
            }
        }
        else {
            return "e"
        }
    }
    
    func isEndIf() -> Bool {
        return type == "if" || type == "else" 
    }
    
    func isConditionCommand() -> Bool {
        return type == "or" || type == "and" || type == "equals"
    }
    
}
