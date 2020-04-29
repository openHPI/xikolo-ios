//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

@available(iOS 11.0, *)
extension Course {

    func dragItem(_ traitCollection: UITraitCollection) -> UIDragItem {

        let userActivity = self.openCourseUserActivity
        let itemProvider = NSItemProvider()
        itemProvider.registerObject(userActivity, visibility: .all)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = self

        dragItem.previewProvider = { () -> UIDragPreview? in
            let courseImage = UIImageView()
            courseImage.sd_setImage(with: self.imageURL)
            let previewWidth = CourseCell.minimalWidth(for: traitCollection)
            let previewHeight = previewWidth / 2
            courseImage.frame = CGRect(x: 0, y: 0, width: previewWidth, height: previewHeight)
            courseImage.layer.roundCorners(for: .default)
            courseImage.contentMode = .scaleAspectFill
            return UIDragPreview(view: courseImage)
        }

        return dragItem
    }

}
