//
//  CourseSectionView.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 23.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CourseHeaderView : UICollectionReusableView {

    @IBOutlet weak var sectionTitleView: UILabel!

    func configure(section: NSFetchedResultsSectionInfo) {
        sectionTitleView.text = section.name
    }

}
