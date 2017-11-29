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

        iconView.image = UIImage(named: "item-\(item.icon)-160")
    }

}
