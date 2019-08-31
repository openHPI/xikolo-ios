//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseItemDetailView: UIView {

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let shimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCompatibility.systemFill
        view.layer.cornerRadius = view.frame.height / 2
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    var isShimmering: Bool = false {
        didSet {
            guard self.isShimmering != oldValue else { return }

            self.stackView.isHidden = self.isShimmering
            self.shimmerView.isHidden = !self.isShimmering

            let animationKey = "shimmer"
            if self.isShimmering, self.shimmerView.layer.animation(forKey: animationKey) == nil {
                self.shimmerView.layer.add(self.pulseAnimation, forKey: animationKey)
            } else {
                self.shimmerView.layer.removeAnimation(forKey: animationKey)
            }
        }
    }

    private var courseItem: CourseItem?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(self.stackView)
        self.addSubview(self.shimmerView)

        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            self.shimmerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            self.shimmerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 3),
            self.shimmerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.shimmerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.shimmerView.layer.cornerRadius = self.shimmerView.frame.height / 2
    }

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let height = max(superSize.height, UIFont.preferredFont(forTextStyle: .caption1).lineHeight)
        return CGSize(width: superSize.width, height: height)
    }

    func configure(for courseItem: CourseItem, with delegate: CourseItemCellDelegate?) {
        self.courseItem = courseItem

        let detailedContent = courseItem.detailedContent
        if !detailedContent.isEmpty {
            self.setContent(detailedContent, inOfflineMode: delegate?.inOfflineMode ?? false)
            self.isHidden = false
        } else if delegate?.isPreloading(for: courseItem.contentType) ?? false {
            self.isShimmering = true
            self.isHidden = false
        } else {
            self.isHidden = true
        }
    }

    private func setContent(_ content: [DetailedData], inOfflineMode isOffline: Bool) {
        self.stackView.arrangedSubviews.forEach { view in
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let video = self.courseItem?.content as? Video

        for contentItem in content {
            let view = DetailedDataView()
            view.configure(for: contentItem, for: video, inOfflineMode: isOffline)
            self.stackView.addArrangedSubview(view)
        }

        self.isShimmering = false
    }

    private var pulseAnimation: CAAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))

        self.traitCollection.performAsCurrent {
            pulseAnimation.fromValue = ColorCompatibility.systemFill.cgColor
            pulseAnimation.toValue = ColorCompatibility.secondarySystemFill.cgColor
        }

        pulseAnimation.duration = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        return pulseAnimation
    }

}

class DetailedDataView: UIStackView {

    var videoId: String?
    var downloadType: String?

    private static let readingTimeFormatter: DateComponentsFormatter = {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()

    private static let videoDurationFormatter: DateComponentsFormatter = {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
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

        if #available(iOS 11, *) {
            imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        }

        return imageView
    }()

    private var progressViewLineWidth: CGFloat {
        if #available(iOS 11, *) {
            return self.traitCollection.preferredContentSizeCategory < .accessibilityMedium ? 1.25 : 2.5
        } else {
            return 1.25
        }
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

    func configure(for data: DetailedData, for video: Video?, inOfflineMode: Bool) {
        self.videoId = video?.id
        self.downloadType = {
            switch data {
            case .stream(duration: _):
                return StreamPersistenceManager.downloadType
            case .slides:
                return SlidesPersistenceManager.downloadType
            default:
                return nil
            }
        }()

        self.spacing = 3.0

        let progressConfiguration: (state: DownloadState, progress: Double?) = {
            guard let video = video else { return (.notDownloaded, nil) }

            switch data {
            case .text(readingTime: _):
                return (.notDownloaded, nil)
            case .stream(duration: _):
                return (StreamPersistenceManager.shared.downloadState(for: video), StreamPersistenceManager.shared.downloadProgress(for: video))
            case .slides:
                return (SlidesPersistenceManager.shared.downloadState(for: video), SlidesPersistenceManager.shared.downloadProgress(for: video))
            case .points(maxPoints: _):
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

    private func textLabel(forContentItem contentItem: DetailedData, in downloadState: DownloadState, inOfflineMode isOffline: Bool) -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true

        let downloaded: Bool
        switch contentItem {
        case let .text(readingTime: readingTime):
            label.text = DetailedDataView.readingTimeFormatter.string(from: readingTime)
            downloaded = true
        case let .stream(duration: duration):
            label.text = DetailedDataView.videoDurationFormatter.string(from: duration)
            downloaded = downloadState == .downloaded
        case .slides:
            label.text = NSLocalizedString("course-item.video.slides.label", comment: "Shown in course content list")
            downloaded = downloadState == .downloaded
        case let .points(maxPoints: maxPoints):
            let format = NSLocalizedString("course-item.max-points", comment: "maximum points for course item")
            let number = NSNumber(value: maxPoints)
            let formattedNumber = DetailedDataView.pointsFormatter.string(from: number)
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
