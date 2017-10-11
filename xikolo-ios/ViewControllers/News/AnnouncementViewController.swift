//
//  AnnouncementViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import Down
import SafariServices

class AnnouncementViewController : UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateView: UILabel!

    var announcement: Announcement!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleView.heroID = "news_headline_" + announcement.id

        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0

        //save read state to server
        self.announcement.visited = true
        TrackingHelper.sendEvent(.visitedAnnouncement, resource: self.announcement)
        SpineHelper.save(AnnouncementSpine.init(announcementItem: self.announcement))

        self.announcement.notifyOnChange(self, updatedHandler: { _ in
            self.updateView()
        }) {
            let isVisible = self.isViewLoaded && self.view.window != nil
            self.navigationController?.popViewController(animated: isVisible)
        }
    }

    private func updateView() {
        self.titleView.text = self.announcement.title

        if let date = self.announcement.published_at {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            self.dateView.text = dateFormatter.string(from: date)
            self.dateView.isHidden = false
        } else {
            self.dateView.isHidden = true
        }

        if let newsText = self.announcement.text, let markDown = try? MarkdownHelper.parse(newsText) {
            self.textView.attributedText = markDown
        } else {
            self.textView.text = "[...]"
        }
        //save read state to server
        announcement.visited = true
        TrackingHelper.sendEvent(.visitedAnnouncement, resource: announcement)
        SpineHelper.save(AnnouncementSpine.init(announcementItem: announcement))
    }

}

extension AnnouncementViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        var url = URL
        if (URL.scheme == "applewebdata") { // replace applewebdata with baseURL for relative urls in markdown
            var absoluteString = URL.absoluteString
            let trimmedUrlString = absoluteString.stringByRemovingRegexMatches(pattern: "^(?:applewebdata://[0-9A-Z-]*/?)", replaceWith: Brand.BaseURL + "/")
            guard let trimmedString = trimmedUrlString else { return false }
            guard let trimmedURL = getURL(forString: trimmedString) else { return false }
            url = trimmedURL
        }
        if !(url.scheme?.hasPrefix("http") ?? false) { // abort if it still isnt http
            return false
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
        safariVC.preferredControlTintColor = Brand.TintColor
        return false
    }

    func getURL(forString string: String) -> URL? {
        return URL(string: string) // necessary because someone clever put the argument in CAPS in the function above
    }

}
