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

class VideoViewController : UIViewController {

    @IBOutlet weak var containerVideoView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var openSlidesButton: UIButton!

    var courseItem: CourseItem!
    var video: Video?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleView.text = courseItem.title
        let videoIncomplete = courseItem.content as! Video
        VideoHelper.syncVideo(videoIncomplete).onSuccess { videoComplete in
            self.video = videoComplete
            if let summary = videoComplete.summary {
                let markDown = try? MarkdownHelper.parse(summary) // TODO: Error handling
                self.descriptionView.attributedText = markDown
            }
            self.performSegue(withIdentifier: "EmbedAVPlayer", sender: self.video)
            self.openSlidesButton.isHidden = self.video?.slides_url == nil
        }
    }

    @IBAction func openSlides(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowSlides", sender: video)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "EmbedAVPlayer"?:
                let destination = segue.destination as! AVPlayerViewController
                let video = sender as! Video
                if let urlString = video.single_stream_hls_url {
                    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    let url = URL(string: urlString)
                    destination.player = AVPlayer(url: url!)
                }
            case "ShowSlides"?:
                let vc = segue.destination as! WebViewController
                let video = sender as! Video
                vc.url = video.slides_url?.absoluteString
        default:
            super.prepare(for: segue, sender: sender)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
            case "EmbedAVPlayer":
                return video != nil
            default:
                return true
        }
    }

}
