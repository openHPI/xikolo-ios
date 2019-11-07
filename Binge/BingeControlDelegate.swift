//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol BingeControlDelegate: AnyObject {

    func startPlayback()
    func pausePlayback()
    func seekTo(progress: Double)
    func seekForwards()
    func seekBackwards()

    func stopAutoHideOfControlsView()
    func toggleFullScreenMode()
    func togglePictureInPictureMode()
    func showMediaSelection(for sourceView: UIView)

    func dismissPlayer()

}
