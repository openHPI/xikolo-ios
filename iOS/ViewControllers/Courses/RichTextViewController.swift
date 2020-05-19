//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SafariServices
import UIKit

class RichTextViewController: UIViewController {

    private static let timeEffortFormatter: DateComponentsFormatter = {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = Locale.autoupdatingCurrent
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var timeEffortView: UIView!
    @IBOutlet private weak var timeEffortLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var loadingScreen: UIView!
    @IBOutlet weak var loadingScreenHeight: NSLayoutConstraint!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var displayIssuesButton: UIButton!

    private var courseItemObserver: ManagedObjectObserver?

    var courseItem: CourseItem! {
        didSet {
            self.courseItemObserver = ManagedObjectObserver(object: self.courseItem) { [weak self] type in
                guard type == .update else { return }
                DispatchQueue.main.async {
                    self?.updateView()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleView.text = self.courseItem.title
        self.loadingScreen.isHidden = false
        self.descriptionView.isHidden = true
        self.displayIssuesButton.isHidden = true

        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0

        if #available(iOS 11, *) {
            // nothing to do here
        } else {
            if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
                self.scrollViewTopConstraint.constant = navigationBarHeight
            }

        }

        self.updateView()
        CourseItemHelper.syncCourseItemWithContent(self.courseItem)
    }

    private func updateView() {
        guard self.viewIfLoaded != nil else { return }

        // Set time effort label
        let roundedTimeEffort = ceil(TimeInterval(self.courseItem.timeEffort) / 60) * 60 // round up to full minutes
        self.timeEffortLabel.text = Self.timeEffortFormatter.string(from: roundedTimeEffort)
        self.timeEffortView.isHidden = self.courseItem.timeEffort == 0

        guard let richtext = self.courseItem.content as? RichText else { return }

        self.textView.setMarkdownWithImages(from: richtext.text)
        self.loadingScreen.isHidden = true
        self.displayIssuesButton.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.richTextViewController.openInWebView(segue: segue) {
            typedInfo.destination.courseItem = self.courseItem
        }
    }

    override func viewWillLayoutSubviews() {
        self.view.layoutSubviews()
        self.loadingScreenHeight.constant = self.view.frame.height / 5
    }

}

extension RichTextViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let appNavigator = self.appNavigator else { return false }
        return !appNavigator.handle(url: URL, on: self)
    }

}

extension RichTextViewController: CourseItemContentPresenter {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
