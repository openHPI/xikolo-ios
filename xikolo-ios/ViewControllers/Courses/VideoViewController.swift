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
    @IBOutlet var descriptionViewHeightConstraint: NSLayoutConstraint!

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
        VideoHelper.sync(video: video).onSuccess { updatedVideo in
            self.show(video: updatedVideo)
        }
    }

    func setupPlayer() {
        BMPlayerConf.topBarShowInCase = .horizantalOnly
        BMPlayerConf.loaderType  = NVActivityIndicatorType.ballScale
        BMPlayerConf.enableVolumeGestures = false
        BMPlayerConf.enableBrightnessGestures = false
        BMPlayerConf.enablePlaytimeGestures = true
        
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

            // update size of description view
            self.descriptionView.textContainerInset = UIEdgeInsets.zero
            let maxSize = CGSize(width: self.descriptionView.bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
            let fittingSize = self.descriptionView.sizeThatFits(maxSize)
            self.descriptionViewHeightConstraint.constant = fittingSize.height
            self.descriptionView.needsUpdateConstraints()
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
        } else {
            videoURL = video.hlsURL
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
        let hiddenBars = UIDevice.current.orientation.isLandscape
        self.navigationController?.setNavigationBarHidden(hiddenBars, animated: true)
        self.tabBarController?.tabBar.isHidden = hiddenBars
    }

}

extension VideoViewController: BMPlayerDelegate {

    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        if state == .bufferFinished {
            player.avPlayer?.rate = self.playerControlView.playRate  // has to be set after playback started
        }
    }

    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {}

    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime : TimeInterval, totalTime: TimeInterval) {}

    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        if playing {
            player.avPlayer?.rate = self.playerControlView.playRate  // has to be set after playback started
        }
    }

}
