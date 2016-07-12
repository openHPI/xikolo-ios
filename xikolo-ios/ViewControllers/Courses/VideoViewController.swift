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
    @IBOutlet weak var previousItemButton: UIButton!
    @IBOutlet weak var nextItemButton: UIButton!

    var courseItem: CourseItem!
    var video: Video?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = courseItem.title
        let videoIncomplete = courseItem.content as! Video
        VideoHelper.syncVideo(videoIncomplete).onSuccess { videoComplete in
            self.video = videoComplete
            self.performSegueWithIdentifier("EmbedAVPlayer", sender: self.video)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! AVPlayerViewController
        let myVideo = sender as! Video
        if let urlString = myVideo.single_stream_hls_url {
            let url = NSURL(string: urlString)
            destination.player = AVPlayer(URL: url!)
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
