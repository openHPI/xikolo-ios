//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class DetailedDataItemView: UIStackView {

    var videoId: String?
    var downloadType: String?

    private static let timeEffortFormatter: DateComponentsFormatter = {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

    private static let timeRemainingFormatter: DateComponentsFormatter = {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        formatter.includesTimeRemainingPhrase = true
        return formatter
    }()

    private static let pointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    private lazy var progressView: CircularProgressView = {
        let progress = CircularProgressView()
        progress.backgroundColor = .white
        progress.lineWidth = self.progressViewLineWidth
        progress.gapWidth = 0.0
        progress.indeterminateProgress = 0.8
        progress.tintColor = Brand.default.colors.primary
        progress.updateProgress(0.33, animated: false)
        progress.widthAnchor.constraint(equalTo: progress.heightAnchor, constant: -4).isActive = true
        return progress
    }()

    private lazy var downloadedIcon: UIImageView = {
        let image = R.image.downloadedTiny()
        let imageView = UIImageView(image: image)
        imageView.bounds = CGRect(x: 0, y: 0, width: 12, height: 14)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorCompatibility.secondaryLabel
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        return imageView
    }()

    private var progressViewLineWidth: CGFloat {
        return self.traitCollection.preferredContentSizeCategory < .accessibilityMedium ? 1.25 : 2.5
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.axis = .horizontal
        self.distribution = .fill
        self.alignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.progressView.lineWidth = self.progressViewLineWidth
    }

    func configure(for data: DetailedDataItem, for video: Video?, inOfflineMode: Bool) {
        self.videoId = video?.id
        self.downloadType = {
            switch data {
            case .timeEffort:
                return video == nil ? nil : StreamPersistenceManager.Configuration.downloadType
            case .slides:
                return SlidesPersistenceManager.Configuration.downloadType
            default:
                return nil
            }
        }()

        self.spacing = 3.0

        let progressConfiguration: (state: DownloadState?, progress: Double?) = {
            guard let video = video else { return (.notDownloaded, nil) } // Currently we only support video course items to be downloaded

            switch data {
            case .timeEffort, .timeRemaining:
                return (StreamPersistenceManager.shared.downloadState(for: video), StreamPersistenceManager.shared.downloadProgress(for: video))
            case .slides:
                return (SlidesPersistenceManager.shared.downloadState(for: video), SlidesPersistenceManager.shared.downloadProgress(for: video))
            case .points:
                return (.notDownloaded, nil)
            }
        }()

        let textLabel = self.textLabel(forContentItem: data, in: progressConfiguration.state, inOfflineMode: inOfflineMode)
        self.addArrangedSubview(textLabel)

        if progressConfiguration.state == .pending || progressConfiguration.state == .downloading {
            self.addArrangedSubview(self.progressView)
            self.progressView.updateProgress(progressConfiguration.progress, animated: false)
        } else if progressConfiguration.state == .downloaded {
            self.addArrangedSubview(self.downloadedIcon)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAssetDownloadProgressNotification(_:)),
                                               name: DownloadProgress.didChangeNotification,
                                               object: nil)
    }

    private func textLabel(forContentItem contentItem: DetailedDataItem, in downloadState: DownloadState?, inOfflineMode isOffline: Bool) -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true

        let downloaded: Bool
        switch contentItem {
        case let .timeRemaining(duration):
            let value = ceil(duration / 60) * 60 // round up to full minutes
            label.text = Self.timeRemainingFormatter.string(from: value)
            downloaded = downloadState == .downloaded
        case let .timeEffort(duration):
            let value = ceil(duration / 60) * 60 // round up to full minutes
            label.text = Self.timeEffortFormatter.string(from: value)
            downloaded = downloadState == .downloaded
        case .slides:
            label.text = NSLocalizedString("course-item.video.slides.label", comment: "Shown in course content list")
            downloaded = downloadState == .downloaded
        case let .points(maxPoints):
            let format = NSLocalizedString("course-item.max-points", comment: "maximum points for course item")
            let number = NSNumber(value: maxPoints)
            let formattedNumber = Self.pointsFormatter.string(from: number)
            label.text = formattedNumber.flatMap { String.localizedStringWithFormat(format, $0) }
            downloaded = false
        }

        label.textColor = downloaded || !isOffline ? ColorCompatibility.secondaryLabel : ColorCompatibility.disabled
        label.sizeToFit()

        return label
    }

    @objc func handleAssetDownloadProgressNotification(_ notification: Notification) {
        guard notification.userInfo?[DownloadNotificationKey.downloadType] as? String == self.downloadType,
              let videoId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
              let progress = notification.userInfo?[DownloadNotificationKey.downloadProgress] as? Double,
              self.videoId == videoId else { return }

        DispatchQueue.main.async {
            self.progressView.updateProgress(progress)
        }
    }

}
