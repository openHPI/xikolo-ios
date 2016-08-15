//
//  ItemVideoLoadingController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 18.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import AVKit
import UIKit

class ItemVideoLoadingController : UIViewController {

    var video: Video!

    override func viewDidLoad() {
        super.viewDidLoad()

        VideoHelper.syncVideo(video).flatMap { video in
            video.loadPoster()
        }.onSuccess {
            self.performSegueWithIdentifier("ShowCourseItemVideoSegue", sender: self.video)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
            case "ShowCourseItemVideoSegue"?:
                // Disable animation so the difference between the loading controller and the actual video controller is invisible.
                let segue = segue as! ReplaceSegue
                segue.animated = false

                let vc = segue.destinationViewController as! AVPlayerViewController
                let video = sender as! Video
                if let url = video.single_stream_hls_url {
                    let playerItem = AVPlayerItem(URL: NSURL(string: url)!)
                    playerItem.externalMetadata = video.metadata()
                    let avPlayer = AVPlayer(playerItem: playerItem)
                    avPlayer.play()
                    vc.player = avPlayer
                }
            default:
                super.prepareForSegue(segue, sender: sender)
        }
    }

}
