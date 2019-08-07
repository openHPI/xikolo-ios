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
    @IBOutlet private weak var detailContentView: CourseItemDetailView!
    @IBOutlet private weak var actionsButton: UIButton!

    var item: CourseItem?
    weak var delegate: (CourseItemCellDelegate & UserActionsDelegate)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.readStateView.layer.cornerRadius = self.readStateView.bounds.width / 2

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAssetDownloadStateChangedNotification(_:)),
                                               name: DownloadState.didChangeNotification,
                                               object: nil)
    }

    func configure(for courseItem: CourseItem) {
        self.item = courseItem
        self.accessibilityIdentifier = "CourseItemCell-\(courseItem.contentType ?? "")"

        let inOfflineMode = self.delegate?.inOfflineMode ?? true
        let isAvailableInOfflineMode = courseItem.content?.isAvailableOffline ?? false
        let isAvailable = !inOfflineMode || isAvailableInOfflineMode

        self.isUserInteractionEnabled = isAvailable

        self.titleView.text = courseItem.title
        if #available(iOS 13, *) {
            self.titleView.textColor = isAvailable ? .label : .tertiaryLabel
        } else {
            self.titleView.textColor = isAvailable ? .black : .lightGray
        }

        self.iconView.image = courseItem.image?.withRenderingMode(.alwaysTemplate)
        if #available(iOS 13, *) {
            self.iconView.tintColor = isAvailable ? .label : .tertiaryLabel
        } else {
            self.iconView.tintColor = isAvailable ? .black : .lightGray
        }

        let wasVisitedBefore = courseItem.visited
        self.readStateView.alpha = wasVisitedBefore ? 0.0 : 1.0
        if #available(iOS 13, *) {
            self.readStateView.backgroundColor = isAvailable ? Brand.default.colors.primary : .tertiaryLabel
        } else {
            self.readStateView.backgroundColor = isAvailable ? Brand.default.colors.primary : .lightGray
        }

        self.configureActionsButton(for: courseItem)
        self.detailContentView.configure(for: courseItem, with: self.delegate)
    }

    private func configureActionsButton(for courseItem: CourseItem) {
        guard let video = courseItem.content as? Video, (video.streamURLForDownload != nil || video.slidesURL != nil) else {
            self.actionsButton.isEnabled = false
            self.actionsButton.alpha = 0
            return
        }

        let isAvailable = !(self.delegate?.inOfflineMode ?? true) || video.isAvailableOffline
        self.actionsButton.isEnabled = isAvailable

        if #available(iOS 13, *) {
            self.actionsButton.tintColor = isAvailable ? Brand.default.colors.primary : .tertiaryLabel
        } else {
            self.actionsButton.tintColor = isAvailable ? Brand.default.colors.primary : .lightGray
        }

        self.actionsButton.alpha = 1
    }

    @IBAction private func tappedActionsButton() {
        guard let video = self.item?.content as? Video else { return }
        self.delegate?.showAlert(with: video.userActions, title: self.item?.title, on: self.actionsButton)
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

}
