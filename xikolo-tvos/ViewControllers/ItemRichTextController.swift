//
//  TextViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 27.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ItemRichTextController : UIViewController {

    @IBOutlet weak var textView: UILabel!

    var courseItem: CourseItem!

    override func viewDidLoad() {
        // TODO: Fetch rich text from API once available.
        var text: String!
        if let title = courseItem.title {
            text = "This is some detailed information for \(title)"
        } else {
            text = "Unknown item."
        }

        textView.attributedText = NSAttributedString(string: text)
    }

}
