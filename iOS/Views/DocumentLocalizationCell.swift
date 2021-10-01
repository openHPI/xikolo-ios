//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class DocumentLocalizationCell: UITableViewCell {

    typealias Delegate = DocumentListViewController

    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var actionsButton: UIButton!
    @IBOutlet private weak var progressView: CircularProgressView!
    @IBOutlet private weak var downloadedIcon: UIImageView!

    private var documentLocalization: DocumentLocalization?

    weak var delegate: Delegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadStateChangedNotification(_:)),
                                       name: DownloadState.didChangeNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadProgressNotification(_:)),
                                       name: DownloadProgress.didChangeNotification,
                                       object: nil)

        self.addDefaultPointerInteraction()
        self.actionsButton.addDefaultPointerInteraction()
    }

    func configure(for documentLocalization: DocumentLocalization) {
        self.documentLocalization = documentLocalization

        let inOfflineMode = self.delegate?.inOfflineMode ?? true
        let isAvailableInOfflineMode = documentLocalization.localFileBookmark != nil
        let isAvailable = !inOfflineMode || isAvailableInOfflineMode

        self.isUserInteractionEnabled = isAvailable

        self.languageLabel.text = documentLocalization.languageCode
        self.languageLabel.textColor = isAvailable ? ColorCompatibility.label : ColorCompatibility.disabled

        self.actionsButton.isEnabled = isAvailable
        self.actionsButton.tintColor = isAvailable ? Brand.default.colors.primary : ColorCompatibility.disabled

        self.actionsButton.add(
            menuActions: [documentLocalization.actions],
            menuTitle: documentLocalization.document.title,
            menuMessage: documentLocalization.languageCode,
            on: self.delegate
        )

        let downloadState = DocumentsPersistenceManager.shared.downloadState(for: documentLocalization)
        self.progressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
        self.progressView.updateProgress(DocumentsPersistenceManager.shared.downloadProgress(for: documentLocalization))
        self.downloadedIcon.isHidden = downloadState != .downloaded
    }

    @objc func handleAssetDownloadStateChangedNotification(_ notification: Notification) {
        guard notification.userInfo?[DownloadNotificationKey.downloadType] as? String == DocumentsPersistenceManager.Configuration.downloadType,
              let documentLocalizationId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
              let downloadStateRawValue = notification.userInfo?[DownloadNotificationKey.downloadState] as? String,
              let downloadState = DownloadState(rawValue: downloadStateRawValue),
              let documentLocalization = self.documentLocalization,
              documentLocalization.id == documentLocalizationId else { return }

        DispatchQueue.main.async {
            self.progressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
            self.progressView.updateProgress(DocumentsPersistenceManager.shared.downloadProgress(for: documentLocalization))
            self.downloadedIcon.isHidden = downloadState != .downloaded
        }
    }

    @objc func handleAssetDownloadProgressNotification(_ notification: Notification) {
        guard notification.userInfo?[DownloadNotificationKey.downloadType] as? String == DocumentsPersistenceManager.Configuration.downloadType,
              let documentLocalizationId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
              let progress = notification.userInfo?[DownloadNotificationKey.downloadProgress] as? Double,
              let documentLocalization = self.documentLocalization,
              documentLocalization.id == documentLocalizationId else { return }

        DispatchQueue.main.async {
            self.progressView.isHidden = false
            self.progressView.updateProgress(progress)
        }
    }

}
