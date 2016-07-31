//
//  ConditionalBuildTableViewCell.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/14/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import UIKit

class ConditionalBuildTableViewCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    
    var command: Command? {
        didSet {
            setLabels()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLabels() {
        typeLabel.text = command?.type
        if command?.type.lowercaseString == "ask" {
            subTitle.text = command?.queryValue
        }
        else if command?.type.lowercaseString == "equals" {
            subTitle.text = "Response to \"\(command!.left!.queryValue)\" equals \"\(command!.value)\""
        }
        else if command?.type.lowercaseString == "say" {
            subTitle.text = command!.value
        }
        else {
            subTitle.text = ""
        }
        
        colorView.layer.backgroundColor = ConditionalBuildViewController.getColorFromCommand(command!.type.lowercaseString).CGColor
    }
    

}
