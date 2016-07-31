//
//  BuildTopicTableViewCell.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/12/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import UIKit
import RealmSwift

class BuildTopicTableViewCell: UITableViewCell {


    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var subLabel: UILabel!
    
    var commandSet: CommandSet! {
        didSet {
            print(commandSet.name)
            self.cellLabel.text = commandSet.name
            self.subLabel.text = commandSet.formatSetData()
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


}
