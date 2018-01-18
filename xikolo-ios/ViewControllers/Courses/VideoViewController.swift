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

    var courseItem: CourseItem!
    var video: Video?
    var videoPlayerConfigured = false
    private var sentFirstAutoPlayEvent = false


    var player: CustomBMPlayer?
    let playerControlView = VideoPlayerControlView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutPlayer()

        self.openSlidesButton.isHidden = true
        self.updateView(for: self.courseItem)
        CourseItemHelper.syncCourseItemWithContent(self.courseItem).onSuccess { objectId in
            CoreDataHelper.viewContext.perform {
                guard let courseItem = CoreDataHelper.viewContext.existingTypedObject(with: objectId) as? CourseItem else {
                    print("Warning: Failed to retrieve course item to display")
                    return
                }

                self.courseItem = courseItem
                DispatchQueue.main.async {
                    self.updateView(for: self.courseItem)
                }
            }
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: NotificationKeys.reachabilityChanged,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toggleControlBars(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if !(self.navigationController?.viewControllers.contains(self) ?? false) {
            self.player?.pause()
        }

        if !(self.navigationController?.viewControllers.contains(self) ?? true) {
            self.trackVideoClose()
        }
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        let orientation = UIDevice.current.orientation
        let isInLandscapeOrientation = orientation == .landscapeRight || orientation == .landscapeLeft
        return UIDevice.current.userInterfaceIdiom == .phone && isInLandscapeOrientation
    }

    func layoutPlayer() {
        self.playerControlView.videoController = self

        BMPlayerConf.topBarShowInCase = .always
        BMPlayerConf.loaderType  = NVActivityIndicatorType.ballScale
        BMPlayerConf.enableVolumeGestures = false
        BMPlayerConf.enableBrightnessGestures = false
        BMPlayerConf.enablePlaytimeGestures = true

        self.playerControlView.changeOrientation(to: UIDevice.current.orientation)
        let player = CustomBMPlayer(customControlView: self.playerControlView)
        player.delegate = self
        player.videoController = self
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

    @objc func reachabilityChanged() {
        self.openSlidesButton.isEnabled = ReachabilityHelper.reachability.isReachable
    }

    private func updateView(for courseItem: CourseItem) {
        self.titleView.text = courseItem.title

        guard let video = courseItem.content as? Video else { return }

        self.show(video: video)
    }

    private func show(video: Video) {
        self.video = video

        // show slides button
        self.openSlidesButton.isHidden = (video.slidesURL == nil)

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
            videoURL = video.singleStream?.hlsURL
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
        if ReachabilityHelper.reachability.isReachable {
            performSegue(withIdentifier: "ShowSlides", sender: self.video)
        } else {
            print("Info: Tapped open slides button without internet, which shouldn't be possible")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowSlides"?:
            if let vc = segue.destination as? WebViewController {
                vc.url = self.video?.slidesURL?.absoluteString
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

extension VideoViewController { // Video tracking

    private var newTrackingContext: [String: String?] {
        var context = [
            "section_id": self.video?.item?.section?.id,
            "course_id": self.video?.item?.section?.course?.id,
            "current_speed": String(self.playerControlView.playRate),
            "current_orientation": UIDevice.current.orientation.isLandscape ? "landscape" : "portrait",
            "current_quality": "hls",
            "current_source": self.playerControlView.offlineLabel.isHidden ? "online" : "offline",
        ]

        if let currentTime = self.player?.avPlayer?.currentTime().seconds {
            context["currentTime"] = String(describing: currentTime)
        }

        return context
    }

    func trackVideoPlay() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackPlay, resourceType: .video, resourceId: video.id, context: self.newTrackingContext)
    }

    func trackVideoPause() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackPause, resourceType: .video, resourceId: video.id, context: self.newTrackingContext)
    }

    func trackVideoPlayRateChange(oldPlayRate: Float, newPlayRate: Float) {
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_speed"] = nil
        context["old_speed"] = String(oldPlayRate)
        context["new_speed"] = String(newPlayRate)
        TrackingHelper.createEvent(.videoPlaybackChangeSpeed, resourceType: .video, resourceId: video.id, context: context)
    }

    func trackVideoSeek(from: TimeInterval?, to: TimeInterval) {
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_time"] = nil
        context["new_current_time"] = String(to)

        if let from = from {
            context["old_current_time"] = String(from)
        }

        TrackingHelper.createEvent(.videoPlaybackSeek, resourceType: .video, resourceId: video.id, context: context)
    }

    func trackVideoEnd() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackEnd, resourceType: .video, resourceId: video.id, context: self.newTrackingContext)
    }

    func trackVideoClose() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackClose, resourceType: .video, resourceId: video.id, context: self.newTrackingContext)
    }

    func trackVideoOrientationChangePortrait() {
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_orientation"] = nil
        TrackingHelper.createEvent(.videoPlaybackDeviceOrientationPortrait, resourceType: .video, resourceId: video.id, context: context)
    }

    func trackVideoOrientationChangeLandscape() {
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_orientation"] = nil
        TrackingHelper.createEvent(.videoPlaybackDeviceOrientationLandscape, resourceType: .video, resourceId: video.id, context: context)
    }

}

extension VideoViewController: BMPlayerDelegate {

    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        if state == .bufferFinished {
            player.avPlayer?.rate = self.playerControlView.playRate  // has to be set after playback started

            if !self.sentFirstAutoPlayEvent {  // only once
                self.trackVideoPlay()
                self.sentFirstAutoPlayEvent = true
            }

        } else if state == .playedToTheEnd {
            self.trackVideoEnd()
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

    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        if UIDevice.current.orientation.isLandscape {
            self.trackVideoOrientationChangeLandscape()
        } else {
            self.trackVideoOrientationChangePortrait()
        }
    }

}
