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

    func configure(_ courseItem: CourseItem,
                   forContentTypes contentTypes: [DetailedContent.Type],
                   forPreloading isPreloading: Bool = false) {
        self.item = courseItem

        self.titleView.text = courseItem.title

        if let iconName = courseItem.iconName {
            self.iconView.image = UIImage(named: "item-\(iconName)-28")
        }

        let wasVisitedBefore = courseItem.visited ?? true
        self.readStateView.backgroundColor = wasVisitedBefore ? UIColor.clear : Brand.TintColor


        // Video download
        if let video = courseItem.content as? Video {
            // customize download button
            let radius: CGFloat = 10.0
            self.downloadButton.tintColor = Brand.TintColor

            self.downloadButton.startDownloadButton.cleanDefaultAppearance()
            let downloadImage = UIImage(named: "cloud-download")?.withRenderingMode(.alwaysTemplate)
            self.downloadButton.startDownloadButton.setTitle(nil, for: .normal)
            self.downloadButton.startDownloadButton.setTitle(nil, for: .highlighted)
            self.downloadButton.startDownloadButton.setImage(downloadImage, for: .normal)
            self.downloadButton.startDownloadButton.setBackgroundImage(nil, for: .normal)
            self.downloadButton.startDownloadButton.setBackgroundImage(nil, for: .highlighted)

            self.downloadButton.pendingView.tintColor = Brand.TintColor
            self.downloadButton.pendingView.radius = radius

            self.downloadButton.stopDownloadButton.tintColor = Brand.TintColor
            self.downloadButton.stopDownloadButton.radius = radius
            self.downloadButton.stopDownloadButton.filledLineWidth = radius
            self.downloadButton.stopDownloadButton.stopButton.isHidden = true

            self.downloadButton.downloadedButton.cleanDefaultAppearance()
            let downloadedImage = UIImage(named: "device-iphone")?.withRenderingMode(.alwaysTemplate)
            self.downloadButton.downloadedButton.setTitle(nil, for: .normal)
            self.downloadButton.downloadedButton.setTitle(nil, for: .highlighted)
            self.downloadButton.downloadedButton.setImage(downloadedImage, for: .normal)
            self.downloadButton.downloadedButton.setBackgroundImage(nil, for: .normal)
            self.downloadButton.downloadedButton.setBackgroundImage(nil, for: .highlighted)

            self.downloadButton.delegate = self

            // set state
            switch VideoPersistenceManager.shared.downloadState(for: video) {
            case .notDownloaded:
                DispatchQueue.main.async {
                    self.downloadButton.state = .startDownload
                }
            case .downloading:
                DispatchQueue.main.async {
                    self.downloadButton.state = .pending
                }
            case .downloaded:
                DispatchQueue.main.async {
                    self.downloadButton.state = .downloaded
                }
            }

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

            self.downloadButton.isHidden = false
        } else {
            self.downloadButton.isHidden = true
        }

        // Content preloading
        guard let detailedContent = courseItem.content as? DetailedContent else {
            // only detailed content items show additional information
            self.detailContainer.isHidden = true
            return
        }

        let contentType = type(of: detailedContent)
        guard contentTypes.contains(where: { String(describing: contentType.self) == String(describing: $0) }) else {
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
        } else if isPreloading {
            self.shimmerContainer.contentView = self.loadingBox
            self.shimmerContainer.isShimmering = true
            self.detailLabel.isHidden = true
            self.shimmerContainer.isHidden = false
            self.detailContainer.isHidden = false
        } else {
            self.detailContainer.isHidden = true
        }
    }

    func removeLoadingState() {
        if self.detailLabel.text?.isEmpty ?? true {
            self.detailContainer.isHidden = true
        }
    }

    func handleAssetDownloadStateChangedNotification(_ noticaition: Notification) {
        guard let videoId = noticaition.userInfo?[Video.Keys.id] as? String,
            let downloadStateRawValue = noticaition.userInfo?[Video.Keys.downloadState] as? String,
            let downloadState = Video.DownloadState(rawValue: downloadStateRawValue),
            let video = self.item?.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            switch downloadState {
            case .downloaded:
                self.downloadButton.state = .downloaded
            case .downloading:
                if self.downloadButton.state != .downloading { // don't go back to pending if already downloading
                    self.downloadButton.state = .pending
                }
            case .notDownloaded:
                self.downloadButton.state = .startDownload
            }
        }
    }

    func handleAssetDownloadProgressNotification(_ noticaition: Notification) {
        guard let videoId = noticaition.userInfo?[Video.Keys.id] as? String,
            let progress = noticaition.userInfo?[Video.Keys.precentDownload] as? Double,
            let video = self.item?.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            if self.downloadButton.state == .pending {
                self.downloadButton.state = .downloading
            }

            self.downloadButton.stopDownloadButton.progress = CGFloat(progress)
        }
    }

}

protocol VideoCourseItemCellDelegate {

    func showAlertForDownloading(of video: Video, forCell cell: CourseItemCell)
    func showAlertForCancellingDownload(of video: Video, forCell cell: CourseItemCell)
    func showAlertForDeletingDownload(of video: Video, forCell cell: CourseItemCell)

}


extension CourseItemCell: PKDownloadButtonDelegate {

    func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        //print("\(downloadButton) -- \(state)")
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
