//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseItemCell: UITableViewCell {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var readStateView: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var detailContentView: CourseItemDetailView!
    @IBOutlet private weak var progressView: CircularProgressView!
    @IBOutlet private weak var actionsButton: UIButton!

    var item: CourseItem?
    weak var delegate: (CourseItemListViewController & UserActionsDelegate)?

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAssetDownloadStateChangedNotification(_:)),
                                               name: NotificationKeys.DownloadStateDidChange,
                                               object: nil)

        self.progressView.isHidden = true
    }

    func configure(for courseItem: CourseItem) {
        self.item = courseItem

        let inOfflineMode = self.delegate?.inOfflineMode ?? true
        let isAvailableInOfflineMode = courseItem.content?.isAvailableOffline ?? false
        let isAvailable = !inOfflineMode || isAvailableInOfflineMode

        self.isUserInteractionEnabled = isAvailable

        self.titleView.text = courseItem.title
        self.titleView.textColor = isAvailable ? UIColor.black : UIColor.lightGray

        self.iconView.image = courseItem.image?.withRenderingMode(.alwaysTemplate)
        self.iconView.tintColor = isAvailable ? UIColor.black : UIColor.lightGray

        let wasVisitedBefore = courseItem.visited
        self.readStateView.alpha = wasVisitedBefore ? 0.0 : 1.0
        self.readStateView.backgroundColor = isAvailable ? Brand.Color.primary : UIColor.lightGray

        self.configureActionsButton(for: courseItem)
        self.detailContentView.configure(for: courseItem, with: self.delegate)
    }

    private func configureActionsButton(for courseItem: CourseItem) {
        guard let video = courseItem.content as? Video, video.streamURLForDownload != nil else {
            self.actionsButton.isHidden = true
            return
        }

        let isAvailable = !(self.delegate?.inOfflineMode ?? true) || video.isAvailableOffline
        self.actionsButton.tintColor = isAvailable ? Brand.Color.primary : UIColor.lightGray
        self.actionsButton.isHidden = false
    }

    @IBAction func tappedActionsButton() {
        guard let video = self.item?.content as? Video else { return }
        self.delegate?.showAlert(with: video.userActions, withTitle: self.item?.title, on: self.actionsButton)
    }

    @objc func handleAssetDownloadStateChangedNotification(_ noticaition: Notification) {
        guard let videoId = noticaition.userInfo?[DownloadNotificationKey.resourceId] as? String,
            let item = self.item,
            let video = item.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            self.configure(for: item)
        }
    }

}
