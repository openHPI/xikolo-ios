//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit
import Down
import SafariServices

class AnnouncementViewController : UIViewController {

    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    var announcement: Announcement!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.courseLabel.textColor = Brand.TintColorSecond

        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0

        self.updateView()
        self.announcement.notifyOnChange(self, updateHandler: {
            self.updateView()
        }) {
            let isVisible = self.isViewLoaded && self.view.window != nil
            self.navigationController?.popViewController(animated: isVisible)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnnouncementHelper.markAsVisited(self.announcement)
        TrackingHelper.createEvent(.visitedAnnouncement, resourceType: .announcement, resourceId: announcement.id)
    }

    private func updateView() {
        if let courseTitle = announcement.course?.title {
            self.courseLabel.text = courseTitle
            self.courseLabel.isHidden = false
        } else {
            self.courseLabel.isHidden = true
        }

        self.titleLabel.text = self.announcement.title

        if let date = self.announcement.publishedAt {
            let dateFormatter = DateFormatter.localizedFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            self.dateLabel.text = dateFormatter.string(from: date)
            self.dateLabel.isHidden = false
        } else {
            self.dateLabel.isHidden = true
        }

        if let newsText = self.announcement.text, let markDown = try? MarkdownHelper.parse(newsText) {
            self.textView.attributedText = markDown
        } else {
            self.textView.text = "[...]"
        }
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
        safariVC.preferredControlTintColor = Brand.windowTintColor
        return false
    }

    func getURL(forString string: String) -> URL? {
        return URL(string: string) // necessary because someone clever put the argument in CAPS in the function above
    }

}
