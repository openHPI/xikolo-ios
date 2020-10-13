//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class AutomatedDownloadSettings: NSObject, NSSecureCoding {

    public enum DownloadOption: Int, CaseIterable {
        case backgroundDownload = 0
        case notification = 1

        public var title: String {
            switch self {
            case .backgroundDownload:
                return "Background Download"
            case .notification:
                return "Notification"
            }
        }

        public var explanation: String {
            switch self {
            case .backgroundDownload:
                return "description for Automated Background Download"
            case .notification:
                return "description for Notification"
            }
        }

        static var `default`: DownloadOption {
            return .backgroundDownload
        }
    }

    public struct MaterialTypes: OptionSet {
        public static let videos = MaterialTypes(rawValue: 1)
        public static let slides = MaterialTypes(rawValue: 1 << 1)

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var allTypesWithTitle: [(type: MaterialTypes, title: String)] {
            return [
                (.videos, NSLocalizedString("settings.downloads.item.video", comment: "download type video")),
                (.slides, NSLocalizedString("settings.downloads.item.slides", comment: "download type slides")),
            ]
        }

        static var `default`: MaterialTypes {
            return MaterialTypes.videos
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
                return "Next Section"
            case .secondNextSection:
                return "Second Next"
            }
        }

        public var explanation: String {
            switch self {
            case .manual:
                return "description for Disabled"
            case .nextSection:
                return "description for Next Section"
            case .secondNextSection:
                return "description for Second Next Section"
            }
        }

        static var `default`: DeletionOption {
            return .nextSection
        }
    }

    public static var supportsSecureCoding: Bool { return true }

    public var downloadOption: DownloadOption
    public var materialTypes: MaterialTypes
    public var deletionOption: DeletionOption

    public override init() {
        self.downloadOption = .default
        self.materialTypes = .default
        self.deletionOption = .default
    }

    public required init(coder decoder: NSCoder) {
        let downloadOptionRawValue = decoder.decodeInteger(forKey: "download_option")
        self.downloadOption = DownloadOption(rawValue: downloadOptionRawValue) ?? .default
        let materialTypesRawValue = decoder.decodeInteger(forKey: "material_types")
        self.materialTypes = MaterialTypes(rawValue: materialTypesRawValue)
        let deletionOptionRawValue = decoder.decodeInteger(forKey: "deletion_option")
        self.deletionOption = DeletionOption(rawValue: deletionOptionRawValue) ?? .default
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.downloadOption.rawValue, forKey: "download_option")
        coder.encode(self.materialTypes.rawValue, forKey: "material_types")
        coder.encode(self.deletionOption.rawValue, forKey: "deletion_option")
    }

}
