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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var openSlidesButton: UIButton!
    @IBOutlet weak var summaryView: UITextView!

    var courseItem: CourseItem!
    var video: Video?

    @IBAction func openSlides(sender: UIButton) {
        performSegueWithIdentifier("ShowSlides", sender: video)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = courseItem.title
        let videoIncomplete = courseItem.content as! Video
        VideoHelper.syncVideo(videoIncomplete).onSuccess { videoComplete in
            self.video = videoComplete
            self.summaryView.text = videoComplete.summary
            self.performSegueWithIdentifier("EmbedAVPlayer", sender: self.video)
            self.openSlidesButton.hidden = self.video?.slides_url == nil
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
            case "EmbedAVPlayer"?:
                let destination = segue.destinationViewController as! AVPlayerViewController
                let video = sender as! Video
                if let urlString = video.single_stream_hls_url {
                    let url = NSURL(string: urlString)
                    destination.player = AVPlayer(URL: url!)
                }
            case "ShowSlides"?:
                let vc = segue.destinationViewController as! WebViewController
                let video = sender as! Video
                vc.url = video.slides_url?.absoluteString
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
            case "EmbedAVPlayer":
                return video != nil
            default:
                return true
        }
    }

}
