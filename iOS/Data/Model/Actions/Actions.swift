//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

struct Action {
    let title: String
    let image: UIImage?
    let handler: () -> Void

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
    }

}

extension UIAlertAction {

    convenience init(action: Action) {
        self.init(title: action.title, style: .default, handler: { _ in action.handler() })
    }

}

@available(iOS 13.0, *)
extension UIAction {

    convenience init(action: Action) {
        self.init(title: action.title, image: action.image, handler: { _ in action.handler() })
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
