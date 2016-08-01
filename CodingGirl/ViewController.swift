//
//  ViewController.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/9/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    var redir = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let realm = try! Realm()
        var topicsLength = realm.objects(Topic).count
        if (topicsLength == 0) {
            let description = "Knowing when to perform an action"
            var testTopic = Topic()
            testTopic.construct("Conditionals", aDescription: description, oProgress: 0.0)
            try! realm.write() {
                realm.add(testTopic)
            }
            print(realm.objects(Topic).count)
        }
        else {
            print("No need to auto-gen: \(realm.objects(Topic).count)");
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if redir {
            performSegueWithIdentifier("goToBuild", sender: self)
        }
        redir = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        print (segue.identifier)
        switch segue.identifier! {
        case "Build Redirect":
            redir = true
            print ("done")
        default:
            print("default reached")
        }
    }


}


