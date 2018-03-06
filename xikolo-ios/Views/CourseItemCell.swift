//
//  CourseItemCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import Shimmer


class CourseItemCell : UITableViewCell {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var readStateView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var detailContainer: UIView!
    @IBOutlet weak var shimmerContainer: FBShimmeringView!
    @IBOutlet weak var loadingBox: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var actionsButton: UIButton!

    var item: CourseItem?
    var delegate: VideoCourseItemCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        // register notification observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadStateChangedNotification(_:)),
                                       name: NotificationKeys.VideoDownloadStateChangedKey,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadProgressNotification(_:)),
                                       name: NotificationKeys.VideoDownloadProgressKey,
                                       object: nil)
    }

    func configure(for courseItem: CourseItem, with configuration: CourseItemCellConfiguration) {
        let isAvailable = !configuration.inOfflineMode || (courseItem.content?.isAvailableOffline ?? false)

        self.isUserInteractionEnabled = isAvailable

        self.item = courseItem
        self.titleView.text = courseItem.title
        self.titleView.textColor = isAvailable ? UIColor.black : UIColor.lightGray
        self.detailLabel.textColor = isAvailable ? UIColor.darkText : UIColor.lightGray

        let iconName = courseItem.icon ?? "document"
        self.iconView.image = UIImage(named: "course-item-icon-\(iconName)")?.withRenderingMode(.alwaysTemplate)
        self.iconView.tintColor = isAvailable ? UIColor.black : UIColor.lightGray

        let wasVisitedBefore = courseItem.visited
        self.readStateView.alpha = wasVisitedBefore ? 0.0 : 1.0
        self.readStateView.backgroundColor = isAvailable ? Brand.TintColor : UIColor.lightGray

        self.configureDownloadButton(for: courseItem, with: configuration)
        self.configureDetailContent(for: courseItem, with: configuration)
    }

    private func configureDownloadButton(for courseItem: CourseItem, with configuration: CourseItemCellConfiguration) {
        guard let video = courseItem.content as? Video, video.singleStream?.hlsURL != nil else {
            self.actionsButton.isHidden = true
            self.progressView.isHidden = true
            return
        }

        self.actionsButton.isHidden = video.alertActions.isEmpty

        let videoDownloadState = VideoPersistenceManager.shared.downloadState(for: video)
        let progress = VideoPersistenceManager.shared.progress(for: video)
        self.progressView.isHidden = videoDownloadState == .notDownloaded || videoDownloadState == .downloaded
        self.progressView.updateProgress(progress)
    }

    private func configureDetailContent(for courseItem: CourseItem, with configuration: CourseItemCellConfiguration) {
        guard configuration.contentTypes.contains(where: { $0.contentType == courseItem.contentType }) else {
            // only certain content items will show additional information
            self.detailContainer.isHidden = true
            return
        }

        self.detailLabel.text = nil
        if let detailedContent = courseItem.content as? DetailedContent, let detailedInfo = detailedContent.detailedInformation {
            self.shimmerContainer.isShimmering = false
            self.detailLabel.text = detailedInfo
            self.detailLabel.isHidden = false
            self.shimmerContainer.isHidden = true
            self.detailContainer.isHidden = false
        } else if configuration.isPreloading {
            self.shimmerContainer.contentView = self.loadingBox
            self.shimmerContainer.isShimmering = true
            self.detailLabel.isHidden = true
            self.shimmerContainer.isHidden = false
            self.detailContainer.isHidden = configuration.inOfflineMode
        } else {
            self.detailContainer.isHidden = true
        }
    }

    @IBAction func tappedActionsButton() {
        guard let video = self.item?.content as? Video else { return }

        self.delegate?.showAlert(with: video.alertActions, on: self.actionsButton)
    }

    @objc func handleAssetDownloadStateChangedNotification(_ noticaition: Notification) {
        guard let videoId = noticaition.userInfo?[Video.Keys.id] as? String,
            let downloadStateRawValue = noticaition.userInfo?[Video.Keys.downloadState] as? String,
            let downloadState = Video.DownloadState(rawValue: downloadStateRawValue),
            let video = self.item?.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            self.progressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
            self.progressView.updateProgress(VideoPersistenceManager.shared.progress(for: video))
        }
    }

    @objc func handleAssetDownloadProgressNotification(_ noticaition: Notification) {
        guard let videoId = noticaition.userInfo?[Video.Keys.id] as? String,
            let progress = noticaition.userInfo?[Video.Keys.precentDownload] as? Double,
            let video = self.item?.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            self.progressView.isHidden = false
            self.progressView.updateProgress(progress)
        }
    }

}


protocol VideoCourseItemCellDelegate {

    func showAlert(with actions: [UIAlertAction], on anchor: UIView)

}

struct CourseItemCellConfiguration {

    let contentTypes: [DetailedContent.Type]
    let isPreloading: Bool
    let inOfflineMode: Bool

}
