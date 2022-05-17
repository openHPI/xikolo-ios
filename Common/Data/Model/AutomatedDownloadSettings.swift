//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class AutomatedDownloadSettings: NSObject, NSSecureCoding {

    public enum NewContentAction: Int {
        case notification = 1
        case notificationAndBackgroundDownload = 2

        public var title: String {
            #warning("TODOL localize")
            switch self {
            case .notification:
                return "Notifications for new content"
            case .notificationAndBackgroundDownload:
                return "Notification for new content & Automated downloads"
            }
        }

        public var explanation: String {
            var explanation = """
            When a new course section becomes available, you will receive a notification. By tapping on this notification, you can open the course directly. If you long press on the notification, you can choose to download all videos from the new section for offline usage.
            """

            if self == .notificationAndBackgroundDownload {
                explanation += """

                In addition, the app attempt to automatically download those files for you. This will only be triggered if your device is connected to a WiFi network.
                """
            }

            return explanation
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
                return "Slides will be downloaded"
            } else {
                return "Only videos will be downloaded"
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
                return "Manual"
            case .nextSection:
                return "With the start of the next course section"
            case .secondNextSection:
                return "With the start of the second next course section"
            }
        }

        public var explanation: String {
            switch self {
            case .manual:
                return "Download content of previous course sections will not be removed automatically."
            case .nextSection:
                return "With the start of a new course section, the downloaded content of previous course sections will be removed from this device."
            case .secondNextSection:
                return "With the start of a new course section, the downloaded content of second last course section (or older) will be removed from this device."
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
