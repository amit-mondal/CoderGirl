//
//  BuildTopicsTableViewController.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/12/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import UIKit
import RealmSwift

class BuildTopicsTableViewController: UITableViewController {
    
    @IBOutlet var tableViewObj: UITableView!
    var commandSets: Results<CommandSet>! {
        didSet {
            tableViewObj.reloadData()
        }
    }
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    var selectedSet: CommandSet?
    let pink = UIColor(netHex: 0xF46197)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewObj.delegate = self
        tableViewObj.dataSource = self
        
        let realm = try! Realm()
        print (realm.objects(CommandSet).count)
        if realm.objects(CommandSet).count <= 0 {
            
            try! realm.write() {
                realm.add(generateInitialSet())
            }
        }
        
        barButton.setTitleTextAttributes([ NSForegroundColorAttributeName : pink, NSFontAttributeName : UIFont(name: "AvenirNext-DemiBold", size: 15)! ], forState: .Normal)
    
        commandSets = realm.objects(CommandSet)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func generateInitialSet() -> CommandSet {
        print("generating initial set")
        var set = CommandSet()
        for index in 0...11 {
            var command = Command()
            switch index {
            case 0:
                command.construct("ask", sInput: "This is an example to teach you some basics (Press \"Return\" to continue)")
            case 1:
                command.construct("ask", sInput: "Use \"Ask\" commands instead of \"Say\" commands when you want me to wait after saying something")
            case 2:
                command.construct("ask", sInput: "You don't always have to use \"Ask\" statements in conditions - they can also be used like a \"Say\" command with a pause at the end")
            case 3:
                command.construct("ask", sInput: "Here's that example conversation you saw in the Learn section")
            case 4:
                command.construct("ask", sInput: "How are you doing today?")
            case 5:
                command.construct("if")
            case 6:
                command.construct("equals", aValue: "good", aLeft: set.commandList[4])
            case 7:
                command.construct("or")
            case 8:
                command.construct("equals", aValue: "great", aLeft: set.commandList[4])
            case 9:
                command.construct("say", sInput: "That's great!")
            case 10:
                command.construct("else")
            case 11:
                command.construct("say", sInput: "Uh-oh")
            default:
                print("uh oh")
            }
            set.name = "Example Command Set"
            set.add(command)
        }
        return set
    }
    
    override func viewDidAppear(animated: Bool) {
        tableViewObj.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commandSets.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("buildCell", forIndexPath: indexPath) as! BuildTopicTableViewCell
        let row = indexPath.row
        let set = commandSets[row]
        cell.commandSet = set

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var set = commandSets[indexPath.row]
        selectedSet = set
        performSegueWithIdentifier("cBuildSegue", sender: self)
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "cBuildSegue" {
            var destination = segue.destinationViewController as! ConditionalBuildViewController
            if let set = self.selectedSet {
                destination.commandSet = set
            }
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let commandSet = commandSets[indexPath.row] as Object
            let realm = try! Realm()
            try! realm.write() {
                realm.delete(commandSet)
            }
            commandSets = realm.objects(CommandSet)
            
        }
    }
    

}
