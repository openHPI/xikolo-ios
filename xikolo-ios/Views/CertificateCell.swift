//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CertificateCell: UITableViewCell {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var subtitleView: UILabel!
    @IBOutlet private weak var progressView: CircularProgressView!

    var item: CourseItem?
    weak var delegate: (CourseItemListViewController & UserActionsDelegate)?

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

//        self.item = courseItem
//        self.titleView.text = courseItem.title
//        self.titleView.textColor = isAvailable ? UIColor.black : UIColor.lightGray
//        self.configureProgressView(for: courseItem)

        self.setNeedsDisplay()
        self.setNeedsLayout()
    }

    private func configureProgressView(for courseItem: CourseItem) {
        guard let video = courseItem.content as? Video, video.singleStream?.hlsURL != nil else {
            self.progressView.isHidden = true
            return
        }

        let videoDownloadState = VideoPersistenceManager.shared.downloadState(for: video)
        let progress = VideoPersistenceManager.shared.progress(for: video)
        self.progressView.isHidden = videoDownloadState == .notDownloaded || videoDownloadState == .downloaded
        self.progressView.updateProgress(progress, animated: false)
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
            //self.configureDetailContent(for: item)
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
