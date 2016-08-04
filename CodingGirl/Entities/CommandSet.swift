//
//  CommandSet.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/15/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class CommandSet: Object {
    dynamic var name = ""
    let commandList = List<Command>()
    let askList = List<Command>()
    let equalsList = List<Command>()
    let ifList = List<Command>()
    let sayList = List<Command>()
    let elseList = List<Command>()
    let andList = List<Command>()
    let orList = List<Command>()
    
    func add(command: Command) {
        commandList.append(command)
        switch command.type.lowercaseString {
            case "ask":
                askList.append(command)
            case "equals":
                equalsList.append(command)
            case "if":
                ifList.append(command)
            case "say":
                sayList.append(command)
            case "else":
                elseList.append(command)
            case "and":
                andList.append(command)
            case "or":
                orList.append(command)
            default:
                print("unsorted command")
        }
    }
    
    func setWithoutElement(sIndex: Int) -> CommandSet {
        let set = CommandSet()
        for index in 0 ... self.commandList.count - 1 {
            if index != sIndex {
                set.add(self.commandList[index])               
            }
        }
        return set
    }
    
    
    func clone() -> CommandSet {
        let set = CommandSet()
        for command in self.commandList {
            set.add(command)
        }
        set.name = self.name
        return set
    }
    
    
    
    func formatSetData() -> String {
        var result = ""
        result = "\(self.commandList.count) Total Commands: \(askList.count) ASK, \(equalsList.count) EQUALS, \(ifList.count) IF, \(sayList.count) SAY, \(elseList.count) ELSE, \(andList.count) AND, and \(orList.count) OR"
        return result
    }
}