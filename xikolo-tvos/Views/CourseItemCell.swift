//
//  CourseItemCell.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseItemCell : UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleView: UILabel!

    func configure(_ item: CourseItem) {
        titleView.text = item.title

        if let iconName = item.iconName {
            iconView.image = UIImage(named: "item-\(iconName)-160")
        }
    }

}
