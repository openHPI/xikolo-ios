//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseDocumentLocalizationCell: UITableViewCell {

    typealias Delegate = DocumentListViewController & UserActionsDelegate

    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var actionsButton: UIButton!
    @IBOutlet private weak var progressView: CircularProgressView!
    @IBOutlet private weak var downloadedIcon: UIImageView!

    private var documentLocalization: DocumentLocalization?

    var delegate: Delegate?

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
    }

    func configure(for documentLocalization: DocumentLocalization) {
        self.documentLocalization = documentLocalization

        let inOfflineMode = self.delegate?.inOfflineMode ?? true
        let isAvailableInOfflineMode = documentLocalization.localFileBookmark != nil
        let isAvailable = !inOfflineMode || isAvailableInOfflineMode

        self.isUserInteractionEnabled = isAvailable

        self.languageLabel.text = documentLocalization.languageCode
        self.languageLabel.textColor = isAvailable ? UIColor.black : UIColor.lightGray

        self.actionsButton.isEnabled = isAvailable
        self.actionsButton.tintColor = isAvailable ? Brand.default.colors.primary : UIColor.lightGray

        let downloadState = DocumentsPersistenceManager.shared.downloadState(for: documentLocalization)
        self.progressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
        self.progressView.updateProgress(DocumentsPersistenceManager.shared.downloadProgress(for: documentLocalization))
        self.downloadedIcon.isHidden = downloadState != .downloaded
    }

    @IBAction func tappedActionsButton() {
        guard let documentLocalization = self.documentLocalization else { return }
        self.delegate?.showAlert(with: documentLocalization.userActions,
                                 title: documentLocalization.document.title,
                                 message: documentLocalization.languageCode,
                                 on: self.actionsButton)
    }

    @objc func handleAssetDownloadStateChangedNotification(_ noticaition: Notification) {
        guard let downloadType = noticaition.userInfo?[DownloadNotificationKey.downloadType] as? String,
            let documentLocalizationId = noticaition.userInfo?[DownloadNotificationKey.resourceId] as? String,
            let downloadStateRawValue = noticaition.userInfo?[DownloadNotificationKey.downloadState] as? String,
            let downloadState = DownloadState(rawValue: downloadStateRawValue),
            let documentLocalization = self.documentLocalization,
            documentLocalization.id == documentLocalizationId else { return }

        if downloadType == DocumentsPersistenceManager.downloadType {
            DispatchQueue.main.async {
                self.progressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
                self.progressView.updateProgress(DocumentsPersistenceManager.shared.downloadProgress(for: documentLocalization))
                self.downloadedIcon.isHidden = downloadState != .downloaded
            }
        }
    }

    @objc func handleAssetDownloadProgressNotification(_ noticaition: Notification) {
        guard let downloadType = noticaition.userInfo?[DownloadNotificationKey.downloadType] as? String,
            let documentLocalizationId = noticaition.userInfo?[DownloadNotificationKey.resourceId] as? String,
            let progress = noticaition.userInfo?[DownloadNotificationKey.downloadProgress] as? Double,
            let documentLocalization = self.documentLocalization,
            documentLocalization.id == documentLocalizationId else { return }

        if downloadType == DocumentsPersistenceManager.downloadType {
            DispatchQueue.main.async {
                self.progressView.isHidden = false
                self.progressView.updateProgress(progress)
            }
        }
    }

}
