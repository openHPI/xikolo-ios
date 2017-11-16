//
//  VideoViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 23.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import BMPlayer
import NVActivityIndicatorView

class VideoViewController : UIViewController {

    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var openSlidesButton: UIButton!

    var courseItem: CourseItem?
    var video: Video?
    var videoPlayerConfigured = false

    var player: BMPlayer?
    let playerControlView = VideoPlayerControlView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupPlayer()

        self.titleView.text = self.courseItem?.title

        guard let video = self.courseItem?.content as? Video else {
            return
        }

        // display local data
        self.show(video: video)

        // refresh data
        VideoHelper.syncVideo(video).onSuccess { updatedVideo in
            self.show(video: updatedVideo)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toggleControlBars(animated)
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        let orientation = UIDevice.current.orientation
        let isInLandscapeOrientation = orientation == .landscapeRight || orientation == .landscapeLeft
        return UIDevice.current.userInterfaceIdiom == .phone && isInLandscapeOrientation
    }

    func setupPlayer() {
        BMPlayerConf.topBarShowInCase = .always
        BMPlayerConf.loaderType  = NVActivityIndicatorType.ballScale
        BMPlayerConf.enableVolumeGestures = false
        BMPlayerConf.enableBrightnessGestures = false
        BMPlayerConf.enablePlaytimeGestures = true

        self.playerControlView.changeOrientation(to: UIDevice.current.orientation)
        let player = BMPlayer(customControlView: self.playerControlView)
        player.delegate = self
        self.videoContainer.addSubview(player)
        player.snp.makeConstraints { (make) in
            make.top.equalTo(self.videoContainer.snp.top)
            make.left.equalTo(self.videoContainer.snp.left)
            make.right.equalTo(self.videoContainer.snp.right)
            make.height.equalTo(self.videoContainer.snp.width).multipliedBy(9.0/16.0)
        }

        self.player = player
        self.videoContainer.layoutIfNeeded()
    }

    func show(video: Video) {
        self.video = video

        // show slides button
        self.openSlidesButton.isHidden = (video.slides_url == nil)

        // show description
        if let summary = video.summary {
            let markDown = try? MarkdownHelper.parse(summary)
            self.descriptionView.attributedText = markDown
            self.descriptionView.isHidden = markDown?.string.isEmpty ?? true
        } else {
            self.descriptionView.isHidden = true
        }

        // configure video player
        guard !self.videoPlayerConfigured else { return }

        // pull latest change for video content item
        video.managedObjectContext?.refresh(video, mergeChanges: true)

        // determine video url (local file, currently downloading or remote)
        var videoURL: URL?
        if let localAsset = VideoPersistenceManager.shared.localAsset(for: video) {
            videoURL = localAsset.url
            self.playerControlView.setOffline(true)
        } else {
            videoURL = video.hlsURL
            self.playerControlView.setOffline(false)
        }

        if let url = videoURL {  // video.hlsURL can be nil
            self.videoPlayerConfigured = true
 
            let asset = BMPlayerResource(url: url, name: self.courseItem?.title ?? "")
            self.player?.setVideo(resource: asset)
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
    }

    @IBAction func openSlides(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowSlides", sender: self.video)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowSlides"?:
            if let vc = segue.destination as? WebViewController {
                vc.url = self.video?.slides_url?.absoluteString
            }
        default:
            super.prepare(for: segue, sender: sender)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.toggleControlBars(true)
        self.playerControlView.changeOrientation(to: UIDevice.current.orientation)
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }

    @discardableResult private func toggleControlBars(_ animated: Bool) -> Bool {
        let hiddenBars = UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone
        self.navigationController?.setNavigationBarHidden(hiddenBars, animated: animated)
        self.tabBarController?.tabBar.isHidden = hiddenBars
        return hiddenBars
    }

}

extension VideoViewController: BMPlayerDelegate {

    private var newTrackingContext: [String: String?] {
        var context = ["section_id": self.video?.item?.section?.id]
        context["course_id"] = self.video?.item?.section?.course?.id
        context["currentTime"] = String(describing: self.player?.avPlayer?.currentTime().seconds ?? 0.0)
        return context
    }

    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        if state == .bufferFinished {
            player.avPlayer?.rate = self.playerControlView.playRate  // has to be set after playback started
        } else if state == .playedToTheEnd {
            TrackingHelper.sendEvent(.videoPlaybackEnd, resource: self.video, context: self.newTrackingContext)
        }
    }

    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
    }

    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime : TimeInterval, totalTime: TimeInterval) {
    }

    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        if playing {
            player.avPlayer?.rate = self.playerControlView.playRate  // has to be set after playback started
        }
    }

}
