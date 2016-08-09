//
//  ConditionalRunViewController.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/15/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import UIKit
import RealmSwift

class ConditionalRunViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputField: UITextField!

    @IBOutlet weak var outputTextView: UITextView!
    
    @IBOutlet weak var speechRect: UITextView!
    
    @IBOutlet weak var setTitleLabel: UILabel!

    @IBOutlet weak var statusButton: UIButton!

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    
    @IBAction func inputFinished(sender: AnyObject) {

    }
    @IBAction func continuePressed(sender: AnyObject) {
        print("inputFinished")
        if inputField.text != nil && inputField.text?.characters.count > 0 {
            if globalAsk != nil {
                let realm = try! Realm()
                try! realm.write() {
                    globalAsk!.response = inputField.text!
                }
            }
        }
        i+=1
        evaluate(commandSet!)
        inputField.text = ""
    }
    
    var hasBegunEvaluating = false
    var i = 0
    var endif = false
    var foundTrue = false
    var foundIf = false
    var commandSet: CommandSet? {
        didSet {
            //evaluate(commandSet!)
            print(commandSet!.commandList.count)
        }
    }

    
    var globalAsk: Command?
    
    func animateTextBox(text: String) {
        UIView.animateWithDuration(200, animations: {
            self.widthConstraint.constant = 300
            }) {[unowned self, text] (finished) in
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.delegate = self
        i = 0
        inputField.userInteractionEnabled = false
        speechRect.hidden = true
        speechRect.superview!.layer.cornerRadius = 5
        speechRect.superview!.layer.borderWidth = 1
        speechRect.superview!.layer.borderColor = UIColor.blackColor().CGColor
        
        if commandSet?.name.characters.count > 0 {
            setTitleLabel.text = commandSet?.name
        }
        else {
            setTitleLabel.text = "New Command Set"
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
            // Do any additional setup after loading the view.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        animateTextBox("")
        if commandSet != nil {
            evaluate(commandSet!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func evaluate(set: CommandSet) {
        //inputField.userInteractionEnabled = false
        self.statusButton.setTitle("Running", forState: .Normal)
        var list = set.commandList
        if (set.elseList.count > set.ifList.count) {
            displayError("Cannot have \"Else\" without \"If\"", eIndex: -1)
            return
        }
        while i < list.count {
            let command: Command = list[i]
            if command.isEndIf() {
                endif = false
            }
            print("i: \(i), endif: \(endif), foundTrue: \(foundTrue) - \(command.type): \(command.value)")
            if !endif {
                
                switch command.type.lowercaseString {
                case "ask":
                    if command.queryValue.characters.count > 0 {
                        inputField.userInteractionEnabled = true
                    }
                    speechRect.hidden = false
                    outputTextView.text = command.queryValue
                    outputTextView.scrollRangeToVisible(NSRange(location:0, length:0))
                    print("Set Label to \(command.queryValue)")
                    globalAsk = command
                    print ("found ask, waiting for input...")
                    self.statusButton.setTitle("Waiting for Input", forState: .Normal)
                    return
                case "equals":
                    displayError("Misplaced \"Equals\" statement - at command \(i+1)", eIndex: i)
                case "if":
                    foundIf = true
                    if i < list.count - 1 && list[i+1].type == "equals" {
                        let conditionCommands = getConditionCommands(set, startIndex: i)
                        let expressionResult = booleanEvaluate(conditionCommands)
                        if expressionResult {
                            print("TRUE")
                            foundTrue = true
                        }
                        else {
                            print("FALSE")
                            endif = true
                        }
                        i += conditionCommands.count
                    }
                    else {
                        displayError("No condition after \"If\" block - at command \(i+1)", eIndex: i )
                    }
                case "say":
                    speechRect.hidden = false
                    outputTextView.text = command.value
                    outputTextView.scrollRangeToVisible(NSRange(location:0, length:0))
                    print("Set Label to \(command.value)")
                case "else":
                    if !foundIf {
                        displayError("Cannot have \"Else\" without \"If\" - at command \(i+1)", eIndex: i)
                        return
                    }
                    foundIf = false
                    if foundTrue {
                        endif = true
                    }
                    foundTrue = false
                case "and":
                    displayError("Misplaced \"And\" statement - at command \(i+1)", eIndex: i )
                case "or":
                    displayError("Misplaced \"Or\" statement - at command \(i+1)", eIndex: i)
                default:
                    displayError("Unknown Command", eIndex: -1)
                }
            }
            i += 1
            if (i >= self.commandSet?.commandList.count) {
                self.statusButton.setTitle("Finished", forState: .Selected)
                self.statusButton.selected = true
            }
        }
    }
    
    
    func getConditionCommands(commandSet: CommandSet, startIndex: Int) -> [Command]{
        print("getting condition commands...")
        var j = startIndex+1
        var conditions: [Command] = []
        var foundConditionEnd: Bool = false
        while !foundConditionEnd {
            if j >= commandSet.commandList.count {
                displayError("No condition end found - at command \(i+commandSet.commandList.count - 1)", eIndex: i+commandSet.commandList.count - 1)
                break
            }
            var command = commandSet.commandList[j]
            if command.isConditionCommand() {
                conditions.append(command)
            }
            else {
                foundConditionEnd = true
            }
            j += 1
        }
        if conditions.count < 1 {
            displayError("No condition after \"If\" block - at command \(i+1)", eIndex: i)
        }
        return conditions
    }
    
    func booleanEvaluate(conditions: [Command]) -> Bool {
        print("evaluating condition booleans...")
        if conditions.count < 1 {
            displayError("No condition after \"If\" block - at command \(i+1)", eIndex: i)
            return false
        }
        var j = 1
        var result = getBoolFromCommand(conditions[0], jIndex: j)
        while j < conditions.count {
            //print("j \(j), count \(conditions.count), condition \((j+2) >= conditions.count)")
            if (j+1) >= conditions.count {
                print()
                displayError("Condition does not correctly place booleans and operators  - near command \(i+j+1)", eIndex: i + j)
            }
            else if conditions[j].type == "and" {
                result = result && getBoolFromCommand(conditions[j+1], jIndex: j)
            }
            else if conditions[j].type == "or" {
                result = result || getBoolFromCommand(conditions[j+1], jIndex: j)
            }
            j+=2
        }
        return result
        
    }
    
    func getBoolFromCommand(command: Command, jIndex: Int) -> Bool {
        if !askExists(self.commandSet!, ask: command.left!) {
            displayError("\"Ask\" command compared in this \"Equals\" command does not exist - at command \(i + jIndex + 1)", eIndex: i + jIndex)
            return false
        }
        if command.evalEquals() == "t" {
            return true
        }
        else if command.evalEquals() == "f" {
            return false
        }
        else {
            displayError("Expected \"Equals\" command, found \(command.type.uppercaseString) instead - at command \(i+jIndex+1)", eIndex: i+jIndex)
            return false
        }
    }
    
    func askExists(set: CommandSet, ask: Command) -> Bool {
        let askList = set.askList
        for sAsk in askList {
            if sAsk.queryValue == ask.queryValue {
                return true
            }
        }
        return false
    }
    
    
    
    func displayError(error: String, eIndex: Int) {
            self.statusButton.tintColor = UIColor.redColor()
            self.statusButton.setTitle("Error Found", forState: .Selected)
            self.statusButton.selected = true
        var alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: {[unowned self, eIndex]  (action) -> Void in
            let buildVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ConditionalBuildViewController
            buildVC.errorIndex = eIndex
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        return true
    }

}
