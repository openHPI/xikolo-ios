//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

struct Action {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    init(title: String, image: UIImage? = nil, handler: @escaping (() -> Void)) {
        self.title = title
        self.image = image
        self.handler = handler
    }

    enum Image {
        static var download: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "square.and.arrow.down")
            } else {
                return nil
            }
        }

        static var aggregatedDownload: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "square.and.arrow.down.on.square")
            } else {
                return nil
            }
        }

        static var stop: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "xmark.circle")
            } else {
                return nil
            }
        }

        static var delete: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "trash")
            } else {
                return nil
            }
        }

        static var share: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "square.and.arrow.up")
            } else {
                return nil
            }
        }

        static var calendar: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "calendar")
            } else {
                return nil
            }
        }

        static var helpdesk: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "questionmark.circle")
            } else {
                return nil
            }
        }

        static var markAsRead: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "checkmark.circle")
            } else {
                return nil
            }
        }

        static var open: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "arrow.right.circle")
            } else {
                return nil
            }
        }
    }

}

extension UIAlertAction {

    convenience init(action: Action) {
        self.init(title: action.title, style: .default) { _ in action.handler() }
    }

}

@available(iOS 13.0, *)
extension UIAction {

    convenience init(action: Action) {
        self.init(title: action.title, image: action.image) { _ in action.handler() }
    }

}

extension Array where Element == Action {

    func asAlertActions() -> [UIAlertAction] {
        return self.map(UIAlertAction.init(action:))
    }

    @available(iOS 13.0, *)
    func asActions() -> [UIAction] {
        return self.map(UIAction.init(action:))
    }

}
