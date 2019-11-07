//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation

protocol BingeMediaSelectionDelegate: AnyObject {

    func select(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup)
    func didCloseMediaSelection()

}
