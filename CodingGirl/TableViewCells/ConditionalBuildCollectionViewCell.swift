//
//  ConditionalBuildCollectionViewCell.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/13/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import UIKit
import Foundation

class ConditionalBuildCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    func deHighlight() {
        contentView.layer.borderWidth = 0
    }
    func highlight(commandString: String) {
        contentView.layer.borderWidth = 3

        contentView.layer.borderColor = ConditionalBuildViewController.getColorFromCommand(commandString).CGColor
    }
}
