//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol BingeControlDelegate: AnyObject {

    func startPlayback()
    func pausePlayback()
    func willSeekTo(progress: Double)
    func seekTo(progress: Double)
    func seekForwards()
    func seekBackwards()

    func stopAutoHideOfControlsOverlay()
    func toggleFullScreenMode()
    func togglePictureInPictureMode()
    func showMediaSelection(for sourceView: UIView)

    func dismissPlayer()

}
