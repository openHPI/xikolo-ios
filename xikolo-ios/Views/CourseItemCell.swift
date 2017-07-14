//
//  CourseItemCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import Shimmer

class CourseItemCell : UITableViewCell {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var readStateView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var detailContainer: UIView!
    @IBOutlet weak var shimmerContainer: FBShimmeringView!
    @IBOutlet weak var loadingBox: UIView!
    @IBOutlet weak var detailLabel: UILabel!

    func configure(_ courseItem: CourseItem) {
        self.titleView.text = courseItem.title

        if let iconName = courseItem.iconName {
            self.iconView.image = UIImage(named: "item-\(iconName)-28")
        }

        let wasVisitedBefore = courseItem.visited ?? true
        self.readStateView.backgroundColor = wasVisitedBefore ? UIColor.clear : Brand.TintColor

        if courseItem.content is Video || courseItem.content is RichText {
            self.detailLabel.isHidden = false

            self.shimmerContainer.contentView = self.loadingBox
            self.shimmerContainer.isShimmering = true

            self.detailContainer.isHidden = false

            // load detail info here
        } else {
            self.detailContainer.isHidden = true
        }
    }

}
