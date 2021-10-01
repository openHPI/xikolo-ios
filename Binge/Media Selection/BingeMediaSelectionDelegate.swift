//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation

protocol BingeMediaSelectionDelegate: AnyObject {

    func select(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup)
    func didCloseMediaSelection()

}
