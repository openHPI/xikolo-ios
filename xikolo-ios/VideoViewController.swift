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

class VideoViewController: UIViewController {

    @IBOutlet weak var containerVideoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var courseItem: CourseItem! {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as!
        AVPlayerViewController
        let url = NSURL(string: "https://player.vimeo.com/external/164726756.m3u8?s=69976e2f9e2216472fa63f8feff4503ee2d6513b&oauth2_token_id=621239406")
        //TODO: insert real link
        destination.player = AVPlayer(URL: url!)
    }
    
    func updateUI() {
        titleLabel?.text = courseItem?.title ?? "default Title"
    }
}
