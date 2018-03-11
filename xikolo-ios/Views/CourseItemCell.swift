//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseItemCell : UITableViewCell {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var readStateView: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var detailContentView: CourseItemDetailView!
    @IBOutlet private weak var progressView: CircularProgressView!
    @IBOutlet private weak var actionsButton: UIButton!

    var item: CourseItem?
    var delegate: CourseItemCellDelegate?

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

    func configure(for courseItem: CourseItem) {
        let isAvailable = !(self.delegate?.inOfflineMode ?? true) || (courseItem.content?.isAvailableOffline ?? false)

        self.isUserInteractionEnabled = isAvailable

        self.item = courseItem
        self.titleView.text = courseItem.title
        self.titleView.textColor = isAvailable ? UIColor.black : UIColor.lightGray

        let iconName = courseItem.icon ?? "document"
        self.iconView.image = UIImage(named: "course-item-icon-\(iconName)")?.withRenderingMode(.alwaysTemplate)
        self.iconView.tintColor = isAvailable ? UIColor.black : UIColor.lightGray

        let wasVisitedBefore = courseItem.visited
        self.readStateView.alpha = wasVisitedBefore ? 0.0 : 1.0
        self.readStateView.backgroundColor = isAvailable ? Brand.TintColor : UIColor.lightGray

        self.configureActionsButton(for: courseItem)
        self.configureProgressView(for: courseItem)
        self.configureDetailContent(for: courseItem)

        self.setNeedsDisplay()
        self.setNeedsLayout()
    }

    private func configureActionsButton(for courseItem: CourseItem) {
        guard let video = courseItem.content as? Video, video.singleStream?.hlsURL != nil else {
            self.actionsButton.isHidden = true
            return
        }

        self.actionsButton.tintColor = .lightGray
        self.actionsButton.isHidden = video.alertActions.isEmpty
    }

    private func configureProgressView(for courseItem: CourseItem) {
        guard let video = courseItem.content as? Video, video.singleStream?.hlsURL != nil else {
            self.progressView.isHidden = true
            return
        }

        let videoDownloadState = VideoPersistenceManager.shared.downloadState(for: video)
        let progress = VideoPersistenceManager.shared.progress(for: video)
        self.progressView.isHidden = videoDownloadState == .notDownloaded || videoDownloadState == .downloaded
        self.progressView.updateProgress(progress)
    }

    private func configureDetailContent(for courseItem: CourseItem) {
        guard self.delegate?.contentToBePreloaded.contains(where: { $0.contentType == courseItem.contentType }) ?? false else {
            // only certain content items will show additional information
            self.detailContentView.isHidden = true
            return
        }

        if let detailedContent = (courseItem.content as? DetailedCourseItem)?.detailedContent, !detailedContent.isEmpty {
            self.detailContentView.setContent(detailedContent, inOfflineMode: self.delegate?.inOfflineMode ?? false)
            self.detailContentView.isHidden = false
        } else if self.delegate?.isPreloading ?? false {
            self.detailContentView.isShimmering = true
            self.detailContentView.isHidden = false //configuration.inOfflineMode
        } else {
            self.detailContentView.isHidden = true
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
            let item = self.item,
            let video = item.content as? Video,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            self.progressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
            self.progressView.updateProgress(VideoPersistenceManager.shared.progress(for: video))
            self.configureDetailContent(for: item)
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


protocol CourseItemCellDelegate {

    var contentToBePreloaded: [DetailedCourseItem.Type] { get }
    var isPreloading: Bool { get }
    var inOfflineMode: Bool { get }

    func showAlert(with actions: [UIAlertAction], on anchor: UIView)

}
