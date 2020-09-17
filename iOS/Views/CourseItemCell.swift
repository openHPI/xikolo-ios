//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseItemCell: UITableViewCell {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var readStateView: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var detailStackView: UIStackView!
    @IBOutlet private weak var actionsButton: UIButton!

    @IBOutlet private weak var leadingSpacerView: UIView!
    @IBOutlet private weak var readStateViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var iconWidthConstraint: NSLayoutConstraint!

    var item: CourseItem?
    weak var delegate: (CourseItemCellDelegate & UIViewController)? // Remove UserActionsDelegate

    var previewView: UIView? {
        return self
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.adaptToTextSizeChange()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAssetDownloadStateChangedNotification(_:)),
                                               name: DownloadState.didChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adaptToTextSizeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)

        self.addDefaultPointerInteraction()
        self.actionsButton.addDefaultPointerInteraction()
    }

    func configure(for courseItem: CourseItem) {
        self.item = courseItem
        self.accessibilityIdentifier = "CourseItemCell-\(courseItem.contentType ?? "")"

        let inOfflineMode = self.delegate?.isInOfflineMode ?? true
        let isAvailableInOfflineMode = courseItem.content?.isAvailableOffline ?? false
        let isAvailable = !inOfflineMode || isAvailableInOfflineMode

        self.titleView.text = courseItem.title
        self.titleView.textColor = isAvailable ? ColorCompatibility.label : ColorCompatibility.disabled

        self.iconView.image = courseItem.image?.withRenderingMode(.alwaysTemplate)
        self.iconView.tintColor = isAvailable ? ColorCompatibility.label : ColorCompatibility.disabled

        let wasVisitedBefore = courseItem.visited
        self.readStateView.alpha = wasVisitedBefore ? 0.0 : 1.0
        self.readStateView.backgroundColor = isAvailable ? Brand.default.colors.primary : ColorCompatibility.disabled

        self.configureActionsButton(for: courseItem)
        self.configureDetailView(for: courseItem)
    }

    private func configureActionsButton(for courseItem: CourseItem) {
        guard let video = courseItem.content as? Video, (video.streamURLForDownload != nil || video.slidesURL != nil) else {
            self.actionsButton.isEnabled = false
            self.actionsButton.alpha = 0
            return
        }

        let isAvailable = !(self.delegate?.isInOfflineMode ?? true) || video.isAvailableOffline
        self.actionsButton.isEnabled = isAvailable
        self.actionsButton.tintColor = isAvailable ? Brand.default.colors.primary : ColorCompatibility.disabled
        self.actionsButton.alpha = 1

        self.actionsButton.add(menuActions: video.actions, menuTitle: self.item?.title, on: self.delegate)
    }

    private func configureDetailView(for courseItem: CourseItem) {
        let video = courseItem.content as? Video
        let isOffline = self.delegate?.isInOfflineMode ?? false

        let newStackViewContentViews = courseItem.detailedContent.map { contentItem -> DetailedDataItemView in
            let view = DetailedDataItemView()
            view.configure(for: contentItem, for: video, inOfflineMode: isOffline)
            return view
        }

        self.detailStackView.arrangedSubviews.forEach { view in
            self.detailStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        newStackViewContentViews.forEach { view in
            self.detailStackView.addArrangedSubview(view)
        }
    }

    @objc func handleAssetDownloadStateChangedNotification(_ notification: Notification) {
        guard let videoId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
            let item = self.item,
            let video = item.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            self.configure(for: item)
        }
    }

    @objc private func adaptToTextSizeChange() {
        if #available(iOS 11, *) {
            let maximalWidth = self.leadingSpacerView.bounds.width - 8
            let preferredWidth = UIFontMetrics.default.scaledValue(for: 8)
            let width = min(preferredWidth, maximalWidth)
            self.readStateViewWidthConstraint.constant = width
            self.readStateView.layer.cornerRadius = width / 2

            let value = UIFontMetrics.default.scaledValue(for: 28)
            self.iconWidthConstraint.constant = value
        } else {
            self.readStateView.layer.cornerRadius = self.readStateView.bounds.width / 2
        }
    }

}
