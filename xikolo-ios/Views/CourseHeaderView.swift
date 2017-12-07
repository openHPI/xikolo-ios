//
//  CourseCell.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 16.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import CoreData

class CourseHeaderView : UICollectionReusableView {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var separator: UIView!


    func configure(_ section: NSFetchedResultsSectionInfo) {
        self.blurView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        self.titleView.text = section.name
        self.titleView.textColor = Brand.TintColorSecond
        self.separator.backgroundColor = Brand.TintColorSecond
    }

}
