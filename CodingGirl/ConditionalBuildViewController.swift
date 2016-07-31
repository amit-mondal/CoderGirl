//
//  ConditionalBuildViewController.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/12/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import UIKit
import RealmSwift

class ConditionalBuildViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var selectedCell: NSIndexPath?
    var commands: [String] = []
    var cleaned = false
    var originalSet: CommandSet?
    var commandSet = CommandSet() {
        didSet {
            if !cleaned {
                let realm = try! Realm()
                var sameNameElements = realm.objects(CommandSet.self).filter("name = '\(self.commandSet.name)'")
                if sameNameElements.count > 0 {
                    var clone = self.commandSet.clone()
                    self.originalSet = self.commandSet
                    self.commandSet = clone
                }
                cleaned = true
            }
            if let tableView = self.tableView {
                tableView.reloadData()
            }
        }
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func addElementPressed(sender: AnyObject) {
        if selectedCell != nil {
            let commandType: String = (commands[selectedCell!.row])
            triggerPopup(commandType.lowercaseString)
        }
    }
    
    
    @IBAction func savePressed(sender: AnyObject) {
        /*
            This is some real sketch shit right here...anyone doing a proper Realm data model should be implementing
            a primary key and updating formally. This is a hacky workaround because Realm doesn't have an auto-incrementing
            primary key
        */
        
        let realm = try! Realm()
        var sameNameElements = realm.objects(CommandSet.self).filter("name = '\(self.commandSet.name)'")
        if sameNameElements.count > 0 && !self.commandSet.invalidated{
            var clone = self.commandSet.clone()
            try! realm.write() {
                if cleaned && self.originalSet != nil {
                    realm.delete(self.originalSet!)
                }
                realm.add(clone)
                cleaned = false
            }
            self.commandSet = clone
        }
        else {
        
            let alertController = UIAlertController(title: "Save", message: "Name this Command Set", preferredStyle: .Alert)
            let save = UIAlertAction(title: "Save", style: .Default, handler: {[unowned self, alertController]  (action) -> Void in
                let realm = try! Realm()
                var sameNameElements = realm.objects(CommandSet.self).filter("name = '\(alertController.textFields![0].text!)'")
                if sameNameElements.count > 0 {
                    var clone = self.commandSet.clone()
                    self.commandSet = clone
                    self.displayError("Cannot have two sets with the same name - please choose a new name")
                } else {
                    self.commandSet.name = alertController.textFields![0].text!
                    try! realm.write() {
                        realm.add(self.commandSet)
                    }
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            var saveTextField: UITextField?
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                saveTextField = textField
                saveTextField?.placeholder = "Enter name here"
            }
            alertController.addAction(save)
            alertController.addAction(cancel)
            presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func triggerPopup(type: String) {
        if type == "ask" {
            var loginTextField: UITextField?
            let alertController = UIAlertController(title: "Ask", message: "What would you like asked?", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: {[unowned self, alertController]  (action) -> Void in
                self.addElement("ask", inputs: [alertController.textFields![0].text!], left: nil, right: nil)
                })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(ok)
            alertController.addAction(cancel)
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                // Enter the textfiled customization code here.
                loginTextField = textField
                loginTextField?.placeholder = "What do you want to ask?"
            }
            presentViewController(alertController, animated: true, completion: nil)
        }
        else if type == "say"{
            var loginTextField: UITextField?
            let alertController = UIAlertController(title: "Say", message: "What should I say?", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: {[unowned self, alertController]  (action) -> Void in
                self.addElement(type, inputs: [alertController.textFields![0].text!], left: nil, right: nil)
                })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(ok)
            alertController.addAction(cancel)
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                // Enter the textfiled customization code here.
                loginTextField = textField
                loginTextField?.placeholder = "What do you want the doll to say?"
            }
            presentViewController(alertController, animated: true, completion: nil)
        }
        else if type == "equals" {
            var loginTextField: UITextField?
            let alertController = UIAlertController(title: "Equals", message: "Check for equality between a string, and the response to some question", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            for value in commandSet.askList {
                let option = UIAlertAction(title: "\"\(value.queryValue)\"", style: .Default, handler: {[unowned self, alertController, value]  (action) -> Void in
                    self.addElement(type, inputs: [alertController.textFields![0].text!], left: value, right: nil)
                    })
                alertController.addAction(option)
            }
            alertController.addAction(cancel)
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                // Enter the textfiled customization code here.
                loginTextField = textField
                loginTextField?.placeholder = "What do you want to check for equality?"
            }
            presentViewController(alertController, animated: true, completion: nil)
        }
        else if type == "if" || type == "else" || type == "or" || type == "and" {
            self.addElement(type, inputs: [], left: nil, right: nil)
        }
    }
    
    func addElement(type: String, inputs: [String], left: Command?, right: Command?) {
        var command = Command()
        if type.lowercaseString == "ask" {
            command.construct(type, sInput: inputs[0])
            commandSet.add(command)
        }
        else if type.lowercaseString == "equals" {
            command.construct(type, aValue: inputs[0], aLeft: left)
            commandSet.add(command)
        }
        else if type.lowercaseString == "say" {
            command.construct("say", sInput: inputs[0])
            commandSet.add(command)
        }
        else if type.lowercaseString == "if" || type.lowercaseString == "else" || type.lowercaseString == "or" || type.lowercaseString == "and" {
            command.construct(type)
            commandSet.add(command)
        }
        tableView.reloadData()
    }
    
    func displayError(error: String) {
        var alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: {[unowned self]  (action) -> Void in
            })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        commands = generateCommandsList()
        

        
        // Do any additional setup after loading the view.
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "runSegue"
        {
            let destination = segue.destinationViewController as! ConditionalRunViewController
            destination.commandSet = commandSet
            print("sending command set from pFS\(commandSet.commandList.count)")
        }
    }
    
    static func getColorFromCommand(commandString: String) -> UIColor {
        var color: UIColor = UIColor.blueColor()
        switch commandString.lowercaseString {
        case "ask":
            color = UIColor.redColor()
        case "equals":
            color = UIColor.orangeColor()
        case "if":
            color = UIColor.yellowColor()
        case "say":
            color = UIColor.greenColor()
        case "else":
            color = UIColor.blueColor()
        case "and":
            color = UIColor.purpleColor()
        case "or":
            color = UIColor.magentaColor()
        default:
            color = UIColor.blueColor()
        }
        return color
    }
 

    func generateCommandsList() -> [String] {
        let commands = ["ask", "if", "equals", "say", "else", "and", "or"]
        return commands
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commands.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cBuildCollCell", forIndexPath: indexPath) as! ConditionalBuildCollectionViewCell
        cell.cellLabel.text = commands[indexPath.row].uppercaseString
        cell.deHighlight()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        if let path = selectedCell {
            if let oldCell = collectionView.cellForItemAtIndexPath(path) as? ConditionalBuildCollectionViewCell {
                oldCell.deHighlight()
            }
        }
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ConditionalBuildCollectionViewCell
        cell.highlight(cell.cellLabel.text!)
        selectedCell = indexPath
    }
}


extension ConditionalBuildViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commandSet.commandList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cBuildBlock", forIndexPath: indexPath) as! ConditionalBuildTableViewCell
        cell.command = commandSet.commandList[indexPath.row]
        return cell
    }
    

}