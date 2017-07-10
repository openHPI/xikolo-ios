//
//  ItemVideoLoadingController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 18.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import AVKit
import UIKit
import SDWebImage

class ItemVideoLoadingController : UIViewController {

    var video: Video!

    override func viewDidLoad() {
        super.viewDidLoad()

        VideoHelper.sync(video: video).onSuccess { _ in
            self.performSegue(withIdentifier: "ShowCourseItemVideoSegue", sender: self.video)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowCourseItemVideoSegue"?:
                // Disable animation so the difference between the loading controller and the actual video controller is invisible.
                let segue = segue as! ReplaceSegue
                segue.animated = false

                let vc = segue.destination as! AVPlayerViewController
                let video = sender as! Video
                if let url = video.single_stream_hls_url {
                    let playerItem = AVPlayerItem(url: URL(string: url)!)
                    playerItem.externalMetadata = video.metadata()
                    let avPlayer = AVPlayer(playerItem: playerItem)
                    avPlayer.play()
                    vc.player = avPlayer
                }
            default:
                super.prepare(for: segue, sender: sender)
        }
    }

}
