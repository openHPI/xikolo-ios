//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class AutomatedDownloadSettings: NSObject, NSSecureCoding {

    public enum NewContentAction: Int {
        case notification = 1
        case notificationAndBackgroundDownload = 2

        public var title: String {
            switch self {
            case .notification:
                return CommonLocalizedString("automated-downloads.feature.title.notification",
                                             comment: "Automated Downloads (Notification only): Title of the feature")
            case .notificationAndBackgroundDownload:
                return CommonLocalizedString("automated-downloads.feature.title.notification-background-download",
                                             comment: "Automated Downloads (Notification + Background Downloads): Title of the feature")
            }
        }

        public var explanation: String {
            var explanation = CommonLocalizedString("automated-downloads.feature.explanation.notification",
                                                    comment: "Automated Downloads (Notification only): Explanation of the feature")

            if self == .notificationAndBackgroundDownload {
                explanation += "\n\n"
                explanation += CommonLocalizedString("automated-downloads.feature.explanation.notification-background-download",
                                                     comment: "Automated Downloads (Notification + Background Downloads): Explanation of the feature (add.)")
            }

            return explanation
        }

        @available(iOS 13.0, *)
        public var decorativeImages: (UIImage?, UIImage?, UIImage?) {  // swiftlint:disable:this large_tuple
            let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .largeTitle, scale: .medium)
            let smallSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1, scale: .small)

            let bellSymbol: UIImage? = {
                if #available(iOS 14, *) {
                    return UIImage(systemName: "bell.badge.fill", withConfiguration: symbolConfiguration)
                } else {
                    return UIImage(systemName: "bell.fill", withConfiguration: symbolConfiguration)
                }
            }()

            switch self {
            case .notification:
                return (bellSymbol, nil, nil)
            case .notificationAndBackgroundDownload:
                return (
                    bellSymbol,
                    UIImage(systemName: "plus", withConfiguration: smallSymbolConfiguration),
                    UIImage(systemName: "square.and.arrow.down.on.square.fill", withConfiguration: symbolConfiguration)
                )
            }
        }
    }

    public struct FileTypes: OptionSet {
        public static let videos = FileTypes(rawValue: 1 << 0)
        public static let slides = FileTypes(rawValue: 1 << 1)

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public var explanation: String {
            if self.contains(.slides) {
                return CommonLocalizedString("automated-downloads.files-type.explanation.videos-slides",
                                             comment: "Automated Downloads (File types): Explanation for considering videos and slides")
            } else {
                return CommonLocalizedString("automated-downloads.files-type.explanation.videos",
                                             comment: "Automated Downloads (File types): Explanation for considering only videos")
            }
        }
    }

    public enum DeletionOption: Int, CaseIterable {
        case manual = 0
        case nextSection = 1
        case secondNextSection = 2

        public var title: String {
            switch self {
            case .manual:
                return CommonLocalizedString("automated-downloads.deletion-options.title.manually",
                                             comment: "Automated Downloads (Deletion options): Title for manual deletion")
            case .nextSection:
                return CommonLocalizedString("automated-downloads.deletion-options.title.next-section",
                                             comment: "Automated Downloads (Deletion options): Title for deletion with next section")
            case .secondNextSection:
                return CommonLocalizedString("automated-downloads.deletion-options.title.second-next-section",
                                             comment: "Automated Downloads (Deletion options): Title for deletion with second next section")
            }
        }

        public var explanation: String {
            switch self {
            case .manual:
                return CommonLocalizedString("automated-downloads.deletion-options.explanation.manual",
                                             comment: "Automated Downloads (Deletion options): Explanation for manual deletion")
            case .nextSection:
                return CommonLocalizedString("automated-downloads.deletion-options.explanation.next-section",
                                             comment: "Automated Downloads (Deletion options): Explanation for deletion with next section")
            case .secondNextSection:
                return CommonLocalizedString("automated-downloads.deletion-options.explanation.second-next-section",
                                             comment: "Automated Downloads (Deletion options): Explanation for deletion with second next section")
            }
        }
    }

    public static var supportsSecureCoding: Bool { return true }

    public var newContentAction: NewContentAction
    public var fileTypes: FileTypes
    public var deletionOption: DeletionOption

    public init(enableBackgroundDownloads: Bool) {
        self.newContentAction = enableBackgroundDownloads ? .notificationAndBackgroundDownload : .notification
        self.fileTypes = .videos
        self.deletionOption = enableBackgroundDownloads ? .nextSection : .manual
    }

    public required init(coder decoder: NSCoder) {
        let newContentActionRawValue = decoder.decodeInteger(forKey: "new_content_option")
        self.newContentAction = NewContentAction(rawValue: newContentActionRawValue) ?? .notification
        let fileTypesRawValue = decoder.decodeInteger(forKey: "file_types")
        self.fileTypes = FileTypes(rawValue: fileTypesRawValue)
        let deletionOptionRawValue = decoder.decodeInteger(forKey: "deletion_option")
        self.deletionOption = DeletionOption(rawValue: deletionOptionRawValue) ?? .manual
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.newContentAction.rawValue, forKey: "new_content_option")
        coder.encode(self.fileTypes.rawValue, forKey: "file_types")
        coder.encode(self.deletionOption.rawValue, forKey: "deletion_option")
    }

}
