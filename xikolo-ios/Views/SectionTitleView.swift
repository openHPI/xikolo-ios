//
//  CourseCell.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 16.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class SectionTitleView : UICollectionReusableView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleView: UILabel!

    func configure(_ title: String) {
        backgroundView.backgroundColor = Brand.TintColorSecond
        titleView.text = title
    }

}
