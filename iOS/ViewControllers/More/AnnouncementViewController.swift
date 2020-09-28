//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SafariServices
import UIKit

class AnnouncementViewController: UIViewController {

    private static let dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .none)

    @IBOutlet private weak var courseButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!

    private var announcementObserver: ManagedObjectObserver?

    private var showCourseTitle: Bool = false
    private var announcement: Announcement! {
        didSet {
            self.announcementObserver = ManagedObjectObserver(object: self.announcement) { [weak self] type in
                guard type == .update else { return }
                DispatchQueue.main.async {
                    self?.updateView()
                }
            }

            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.courseButton.tintColor = Brand.default.colors.secondary
        self.courseButton.addDefaultPointerInteraction()

        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnnouncementHelper.markAsVisited(self.announcement)
        TrackingHelper.createEvent(.visitedAnnouncement, resourceType: .announcement, resourceId: announcement.id, on: self)
    }

    func configure(for announcement: Announcement, showCourseTitle: Bool) {
        self.showCourseTitle = showCourseTitle
        self.announcement = announcement
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
            self.dateLabel.text = Self.dateFormatter.string(from: date)
            self.dateLabel.isHidden = false
        } else {
            self.dateLabel.isHidden = true
        }

        self.textView.setMarkdownWithImages(from: self.announcement.text)

    }

    @IBAction private func openCourse() {
        guard let course = announcement.course else { return }
        self.appNavigator?.show(course: course, userInitialized: false)
    }

}

extension AnnouncementViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let appNavigator = self.appNavigator else { return false }
        return !appNavigator.handle(url: URL, on: self, userInitialized: true)
    }

}
