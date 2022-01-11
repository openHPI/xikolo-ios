//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

public protocol BingePlayerDelegate: AnyObject {

    func didConfigure()
    func didStartPlayback()
    func didPausePlayback()
    func didChangePlaybackRate(from oldRate: Float, to newRate: Float)
    func didSeek(from oldTime: TimeInterval, to newTime: TimeInterval)
    func didReachEndOfPlayback()
    func didChangeSubtitles(from oldLanguageCode: String?, to newLanguageCode: String?)
    func didChangeLayout(from oldLayout: LayoutState, to newLayout: LayoutState)
    func didChangeOrientation(to orientation: UIInterfaceOrientation?)

}

public extension BingePlayerDelegate {

    func didConfigure() {}
    func didStartPlayback() {}
    func didPausePlayback() {}
    func didChangePlaybackRate(from oldRate: Float, to newRate: Float) {}
    func didSeek(from oldTime: TimeInterval, to newTime: TimeInterval) {}
    func didReachEndOfPlayback() {}
    func didChangeSubtitles(from oldLanguageCode: String?, to newLanguageCode: String?) {}
    func didChangeLayout(from oldLayout: LayoutState, to newLayout: LayoutState) {}
    func didChangeOrientation(to orientation: UIInterfaceOrientation?) {}

}
