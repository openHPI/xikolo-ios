//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVKit
import BMPlayer

private var playerViewControllerKVOContext = 0

class CustomBMPlayer: BMPlayer {

    weak var videoController: VideoViewController?

    private(set) var pictureInPictureController: AVPictureInPictureController?

    override func seek(_ to: TimeInterval, completion: (() -> Void)? = nil) { // swiftlint:disable:this identifier_name
        let from = self.playerLayer?.player?.currentTime().seconds
        super.seek(to, completion: completion)
        self.videoController?.trackVideoSeek(from: from, to: to)
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerViewControllerKVOContext else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        if keyPath == "pictureInPicturePossible" {
            let pictureInPicturePossible = self.pictureInPictureController?.isPictureInPicturePossible ?? false
            self.controlView.adaptToPictureInPicturePossible(pictureInPicturePossible)
        }
    }

    override func reactOnPlayerStateChange(state: BMPlayerState)  {
        self.setupPictureInPictureViewController()
    }

    private func setupPictureInPictureViewController() {
        guard self.pictureInPictureController == nil else { return }
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }
        guard let playerLayer = self.playerLayer?.playerLayer else { return }

        self.pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
        self.pictureInPictureController?.delegate = self
        self.pictureInPictureController?.addObserver(self, forKeyPath: "pictureInPicturePossible", options: [.new, .initial], context: &playerViewControllerKVOContext)
    }

    func togglePictureInPictureMode() {
        guard let pictureInPictureController = self.pictureInPictureController else { return }

        if pictureInPictureController.isPictureInPictureActive {
            pictureInPictureController.stopPictureInPicture()
        } else {
            pictureInPictureController.startPictureInPicture()
        }
    }

}

extension CustomBMPlayer: AVPictureInPictureControllerDelegate {

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Update video controls of main player to reflect the current state of the video playback.
        // You may want to update the video scrubber position.
        completionHandler(true)
    }

    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.controlView.controlViewAnimation(isShow: false)
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                           failedToStartPictureInPictureWithError error: Error) {
        self.controlView.controlViewAnimation(isShow: !self.isPlaying)
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.controlView.controlViewAnimation(isShow: !self.isPlaying)
    }


}
