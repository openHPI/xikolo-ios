//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseItemHeader: UITableViewHeaderFooterView {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var actionsButton: UIButton!

    private weak var section: CourseSection?
    private var inOfflineMode: (() -> Bool)?

    weak var delegate: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleView.textColor = ColorCompatibility.secondaryLabel

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAssetDownloadStateChangedNotification(_:)),
                                               name: DownloadState.didChangeNotification,
                                               object: nil)

        self.actionsButton.addDefaultPointerInteraction()
    }

    func configure(for section: CourseSection, inOfflineMode: @escaping () -> Bool) {
        self.section = section
        self.inOfflineMode = inOfflineMode
        self.updateContent()
    }

    private func updateContent() {
        let isInOfflineMode = self.inOfflineMode?() ?? false
        let hasContentToShow = !isInOfflineMode || !(self.section?.userActions.isEmpty ?? false)
        self.titleView.text = self.section?.title
        self.actionsButton.isHidden = !(self.section?.hasUserActions ?? false)
        self.actionsButton.isEnabled = hasContentToShow
        self.actionsButton.tintColor = hasContentToShow ? Brand.default.colors.primary : ColorCompatibility.secondaryLabel

        let spinnerTitle = NSLocalizedString("course-section.loading-spinner.title",
                                             comment: "title for spinner when loading section content")
        let isLoadingRequired = { !(self.section?.allVideosPreloaded ?? false) }
        let load: (@escaping () -> Void) -> Void = { completion in
            if let section = self.section {
                CourseItemHelper.syncCourseItems(forSection: section, withContentType: Video.contentType).onComplete { _ in
                    completion()
                }
            } else {
                completion()
            }
        }
        let actions = { self.section?.userActions ?? [] }
        let deferredMenuActionsConfiguration = DeferredMenuActionConfiguration(loadingMessage: spinnerTitle, isLoadingRequired: isLoadingRequired, load: load, actions: actions)

        self.actionsButton.add(deferredMenuActions: deferredMenuActionsConfiguration, menuTitle: self.section?.title, on: self.delegate)
    }

    @objc func handleAssetDownloadStateChangedNotification(_ notification: Notification) {
        guard let videoId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
              let section = self.section,
              let videoIDs = self.section?.items.compactMap({ $0.content as? Video }).map(\.id),
              videoIDs.contains(videoId) else { return }

        DispatchQueue.main.async {
            self.updateContent()
        }
    }

}
