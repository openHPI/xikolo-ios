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
    @IBOutlet weak var downloadButton: UIButton!

    var item: CourseItem?

    func configure(_ courseItem: CourseItem,
                   forContentTypes contentTypes: [DetailedContent.Type],
                   forPreloading isPreloading: Bool = false) {
        self.item = courseItem

        self.titleView.text = courseItem.title

        if let iconName = courseItem.iconName {
            self.iconView.image = UIImage(named: "item-\(iconName)-28")
        }

        let wasVisitedBefore = courseItem.visited ?? true
        self.readStateView.backgroundColor = wasVisitedBefore ? UIColor.clear : Brand.TintColor


        // Video download
        self.downloadButton.isHidden = !(courseItem.content is Video)


        // Content preloading
        guard let detailedContent = courseItem.content as? DetailedContent else {
            // only detailed content items show additional information
            self.detailContainer.isHidden = true
            return
        }

        let contentType = type(of: detailedContent)
        guard contentTypes.contains(where: { String(describing: contentType.self) == String(describing: $0) }) else {
            // only certain content items will show additional information
            self.detailContainer.isHidden = true
            return
        }

        self.detailLabel.text = nil
        if let detailedInfo = detailedContent.detailedInformation {
            self.shimmerContainer.isShimmering = false
            self.detailLabel.text = detailedInfo
            self.detailLabel.isHidden = false
            self.shimmerContainer.isHidden = true
            self.detailContainer.isHidden = false
        } else if isPreloading {
            self.shimmerContainer.contentView = self.loadingBox
            self.shimmerContainer.isShimmering = true
            self.detailLabel.isHidden = true
            self.shimmerContainer.isHidden = false
            self.detailContainer.isHidden = false
        } else {
            self.detailContainer.isHidden = true
        }
    }

    func removeLoadingState() {
        if self.detailLabel.text?.isEmpty ?? true {
            self.detailContainer.isHidden = true
        }
    }


    @IBAction func handleVideoDownload() {
        print("hello")
        if let video = self.item?.content as? Video {
            VideoPersistenceManager.shared.downloadStream(for: video)
        }

    }


}
