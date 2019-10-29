//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import UIKit

protocol BingeMediaSelectionDelegate: AnyObject { // TODO: split into delegate and datasource
    var currentMediaSelection: AVMediaSelection? { get }
    func select(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup)
    func didCloseMediaSelection()
}
