//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

public protocol BingePlayerDelegate: AnyObject {

    func didConfigure()
    func didStartPlayback()
    func didPausePlayback()
    func didChangePlaybackRate(from oldRate: Float, to newRate: Float)
    func didSeek(from oldTime: TimeInterval, to newTime: TimeInterval)
    func didReachEndofPlayback()
    func didChangeSubtitles(from oldLanguageCode: String?, to newLanguageCode: String?)
    func didChangeLayout(from oldLayout: LayoutState, to newLayout: LayoutState)
    func didChangeOrientation(to orientation: UIInterfaceOrientation)

}

public extension BingePlayerDelegate {

    func didConfigure() {}
    func didStartPlayback() {}
    func didPausePlayback() {}
    func didChangePlaybackRate(from oldRate: Float, to newRate: Float) {}
    func didSeek(from oldTime: TimeInterval, to newTime: TimeInterval) {}
    func didReachEndofPlayback() {}
    func didChangeSubtitles(from oldLanguageCode: String?, to newLanguageCode: String?) {}
    func didChangeLayout(from oldLayout: LayoutState, to newLayout: LayoutState) {}
    func didChangeOrientation(to orientation: UIInterfaceOrientation) {}

}
