//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Down
import SafariServices
import UIKit

class AnnouncementViewController: UIViewController {

    @IBOutlet private weak var courseButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!

    var announcement: Announcement!
    var showCourseTitle: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.courseButton.tintColor = Brand.default.colors.secondary

        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0

        self.updateView()

        // swiftlint:disable:next multiline_arguments
        self.announcement.notifyOnChange(self, updateHandler: {
            self.updateView()
        }, deleteHandler: {
            let isVisible = self.isViewLoaded && self.view.window != nil
            self.navigationController?.popViewController(animated: isVisible)
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnnouncementHelper.shared.markAsVisited(self.announcement)
        TrackingHelper.createEvent(.visitedAnnouncement, resourceType: .announcement, resourceId: announcement.id)
    }

    private func updateView() {
        if let courseTitle = announcement.course?.title, self.showCourseTitle {
            self.courseButton.setTitle(courseTitle, for: .normal)
            self.courseButton.isHidden = false
        } else {
            self.courseButton.isHidden = true
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

        if let newsText = self.announcement.text {
            MarkdownHelper.attributedString(for: newsText).onSuccess(DispatchQueue.main.context) { attributedString in
                self.textView.attributedText = attributedString
            }
        } else {
            self.textView.text = "[...]"
        }
    }

    @IBAction func tappedCourseTitle() {
        guard let course = announcement.course else { return }
        AppNavigator.show(course: course)
    }

}

extension AnnouncementViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return !AppNavigator.handle(URL, on: self)
    }

}
