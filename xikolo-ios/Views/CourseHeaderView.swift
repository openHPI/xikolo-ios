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

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleView: UILabel!

    func configure(_ section: NSFetchedResultsSectionInfo) {
        backgroundView.backgroundColor = Brand.TintColorSecond
        backgroundView.isHidden = false
        titleView.text = section.name
    }

}
