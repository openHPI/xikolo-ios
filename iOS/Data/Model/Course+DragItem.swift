//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension Course {

    func dragItem(with previewView: UIView?) -> UIDragItem {
        let userActivity = self.openCourseUserActivity
        let itemProvider = NSItemProvider(object: self)
        itemProvider.registerObject(userActivity, visibility: .all)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = self

        // Use default preview if no preview view was passed
        dragItem.previewProvider = previewView.flatMap { view -> (() -> UIDragPreview?) in
            return { () -> UIDragPreview? in
                return UIDragPreview(view: view)
            }
        }

        return dragItem
    }

}
