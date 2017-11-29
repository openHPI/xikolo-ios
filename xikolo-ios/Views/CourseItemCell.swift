//
//  CourseItemCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import DownloadButton
import Shimmer


class CourseItemCell : UITableViewCell {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var readStateView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var detailContainer: UIView!
    @IBOutlet weak var shimmerContainer: FBShimmeringView!
    @IBOutlet weak var loadingBox: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var downloadButton: PKDownloadButton!

    var item: CourseItem?
    var delegate: VideoCourseItemCellDelegate?

    var singleReloadInProgress = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupDownloadButton()

        // register notification observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(CourseItemCell.handleAssetDownloadStateChangedNotification(_:)),
                                       name: NotificationKeys.VideoDownloadStateChangedKey,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(CourseItemCell.handleAssetDownloadProgressNotification(_:)),
                                       name: NotificationKeys.VideoDownloadProgressKey,
                                       object: nil)
    }

    private func setupDownloadButton() {
        let radius: CGFloat = 10.0
        self.downloadButton.tintColor = Brand.TintColor

        self.downloadButton.startDownloadButton.cleanDefaultAppearance()
        self.downloadButton.startDownloadButton.setTitle(nil, for: .normal)
        self.downloadButton.startDownloadButton.setTitle(nil, for: .highlighted)
        let downloadImage = UIImage(named: "cloud-download")?.withRenderingMode(.alwaysTemplate)
        self.downloadButton.startDownloadButton.setImage(downloadImage, for: .normal)
        self.downloadButton.startDownloadButton.setBackgroundImage(nil, for: .normal)
        self.downloadButton.startDownloadButton.setBackgroundImage(nil, for: .highlighted)

        self.downloadButton.pendingView.tintColor = Brand.TintColor
        self.downloadButton.pendingView.radius = radius

        self.downloadButton.stopDownloadButton.tintColor = Brand.TintColor
        self.downloadButton.stopDownloadButton.radius = radius
        self.downloadButton.stopDownloadButton.filledLineWidth = radius - 0.5  // so there will be no dot in the center of the progress
        self.downloadButton.stopDownloadButton.stopButtonWidth = 0

        self.downloadButton.downloadedButton.cleanDefaultAppearance()
        self.downloadButton.downloadedButton.setTitle(nil, for: .normal)
        self.downloadButton.downloadedButton.setTitle(nil, for: .highlighted)
        let downloadedImage = UIImage(named: "device")?.withRenderingMode(.alwaysTemplate)
        self.downloadButton.downloadedButton.setImage(downloadedImage, for: .normal)
        self.downloadButton.downloadedButton.setBackgroundImage(nil, for: .normal)
        self.downloadButton.downloadedButton.setBackgroundImage(nil, for: .highlighted)

        self.downloadButton.delegate = self
    }

    func configure(for courseItem: CourseItem, with configuration: CourseItemCellConfiguration) {
        let isAvailable = !configuration.inOfflineMode || (courseItem.content?.isAvailableOffline ?? false)

        self.isUserInteractionEnabled = isAvailable

        self.item = courseItem
        self.titleView.text = courseItem.title
        self.titleView.textColor = isAvailable ? UIColor.black : UIColor.lightGray
        self.detailLabel.textColor = isAvailable ? UIColor.darkText : UIColor.lightGray

        self.iconView.tintColor = isAvailable ? UIColor.black : UIColor.lightGray
        if let icon = UIImage(named: "course-item-icon-\(courseItem.icon)") {
            self.iconView.image = icon.withRenderingMode(.alwaysTemplate)
        } else {
            self.iconView.image = UIImage(named: "course-item-icon-document")?.withRenderingMode(.alwaysTemplate)
        }

        let wasVisitedBefore = courseItem.visited ?? true
        self.readStateView.alpha = wasVisitedBefore ? 0.0 : 1.0
        self.readStateView.backgroundColor = isAvailable ? Brand.TintColor : UIColor.lightGray

        self.configureDownloadButton(for: courseItem, with: configuration)
        self.configureDetailContent(for: courseItem, with: configuration)
    }

    private func configureDownloadButton(for courseItem: CourseItem, with configuration: CourseItemCellConfiguration) {
        if let video = courseItem.content as? Video {
            let videoDownloadState = VideoPersistenceManager.shared.downloadState(for: video)
            var newButtonState = self.downloadButtonState(for: videoDownloadState)

            if newButtonState == .startDownload && self.singleReloadInProgress {
                newButtonState = .pending
            }

            DispatchQueue.main.async {
                self.downloadButton.state = newButtonState
                if newButtonState == .pending {
                    self.downloadButton.pendingView.startSpin()
                } else if newButtonState == .downloading, let progress = VideoPersistenceManager.shared.progress(for: video) {
                    self.downloadButton.stopDownloadButton.progress = CGFloat(progress)
                }
            }

            if configuration.inOfflineMode && !video.isAvailableOffline {
                if newButtonState == .startDownload {
                    self.downloadButton.isHidden = true
                } else if newButtonState == .pending || newButtonState == .pending {
                    self.downloadButton.alpha = 0.5
                    self.downloadButton.isHidden = false
                } else {
                    // should never, but just in case if 'isAvailableOffline' is modified
                    self.downloadButton.alpha = 1.0
                    self.downloadButton.isHidden = false
                }
            } else {
                self.downloadButton.alpha = 1.0
                self.downloadButton.isHidden = false
            }
        } else {
            self.downloadButton.isHidden = true
        }
    }

    private func configureDetailContent(for courseItem: CourseItem, with configuration: CourseItemCellConfiguration) {
        guard let detailedContent = courseItem.content as? DetailedContent else {
            // only detailed content items show additional information
            self.detailContainer.isHidden = true
            return
        }

        let contentType = type(of: detailedContent)
        guard configuration.contentTypes.contains(where: { String(describing: contentType.self) == String(describing: $0) }) else {
            // only certain content items will show additional information
            self.detailContainer.isHidden = true
            return
        }

        self.detailLabel.text = nil
        if let detailedInfo = detailedContent.detailedInformation {
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

    func removeLoadingState() {
        if self.detailLabel.text?.isEmpty ?? true {
            self.detailContainer.isHidden = true
        }
    }

    @objc func handleAssetDownloadStateChangedNotification(_ noticaition: Notification) {
        guard let videoId = noticaition.userInfo?[Video.Keys.id] as? String,
            let downloadStateRawValue = noticaition.userInfo?[Video.Keys.downloadState] as? String,
            let downloadState = Video.DownloadState(rawValue: downloadStateRawValue),
            let video = self.item?.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            // Update UI
            self.downloadButton.state = self.downloadButtonState(for: downloadState)

            self.delegate?.videoCourseItemCell(self, downloadStateDidChange: downloadState)
        }
    }

    @objc func handleAssetDownloadProgressNotification(_ noticaition: Notification) {
        guard let videoId = noticaition.userInfo?[Video.Keys.id] as? String,
            let progress = noticaition.userInfo?[Video.Keys.precentDownload] as? Double,
            let video = self.item?.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            self.downloadButton.state = .downloading
            self.downloadButton.stopDownloadButton.progress = CGFloat(progress)
        }
    }

    private func downloadButtonState(for videoDownloadState: Video.DownloadState) -> PKDownloadButtonState {
        switch videoDownloadState {
        case .notDownloaded:
            return .startDownload
        case .pending:
            return .pending
        case .downloading:
            return .downloading
        case .downloaded:
            return .downloaded
        }
    }

}


protocol VideoCourseItemCellDelegate {

    func showAlertForDownloading(of video: Video, forCell cell: CourseItemCell)
    func showAlertForCancellingDownload(of video: Video, forCell cell: CourseItemCell)
    func showAlertForDeletingDownload(of video: Video, forCell cell: CourseItemCell)

    func videoCourseItemCell(_ cell: CourseItemCell, downloadStateDidChange newState: Video.DownloadState)

}


extension CourseItemCell: PKDownloadButtonDelegate {

    func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        guard let video = self.item?.content as? Video else { return }

        switch state {
        case .startDownload:
            self.delegate?.showAlertForDownloading(of: video, forCell: self)
        case .downloaded:
            self.delegate?.showAlertForDeletingDownload(of: video, forCell: self)
        default:  // pending + downloading
            self.delegate?.showAlertForCancellingDownload(of: video, forCell: self)
        }
    }

}

struct CourseItemCellConfiguration {

    let contentTypes: [DetailedContent.Type]
    let isPreloading: Bool
    let inOfflineMode: Bool

}
