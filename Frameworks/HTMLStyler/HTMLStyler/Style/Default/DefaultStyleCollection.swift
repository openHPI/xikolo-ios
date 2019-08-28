//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct DefaultStyleCollection: StyleCollection {

    let tintColor: UIColor
    let imageLoader: ImageLoader.Type

    public init(tintColor: UIColor, imageLoader: ImageLoader.Type = DefaultImageLoader.self) {
        self.tintColor = tintColor
        self.imageLoader = imageLoader
    }

    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        paragraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        return paragraphStyle
    }

    public var baseStyle: Style {
        let foregroundColor: UIColor = {
            /*if #available(iOS 13, *) {
                return .label
            } else { */
                return .black
            //}
        }()

        return [
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            .foregroundColor: foregroundColor,
            .paragraphStyle: self.paragraphStyle,
        ]
    }

    public func style(for tag: Tag, isLastSibling: Bool) -> Style? {
        switch tag {
        case .headline1:
            let paragraphStyle = self.paragraphStyle
            paragraphStyle.paragraphSpacingBefore = UIFont.labelFontSize
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.30, weight: .bold),
                .paragraphStyle: paragraphStyle,
            ]
        case .headline2:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.25, weight: .bold)
            ]
        case .headline3:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.20, weight: .bold)
            ]
        case .headline4:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.15, weight: .bold)
            ]
        case .headline5:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.10, weight: .bold)
            ]
        case .headline6:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.05, weight: .bold)
            ]
        case .bold:
            return [
                .font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
            ]
        case .italic:
            return [
                .font: UIFont.italicSystemFont(ofSize: UIFont.labelFontSize)
            ]
        case let .link(url):
            return [
                .link: url,
                .foregroundColor: self.tintColor,
            ]
        case .code:
            return [
                .font: UIFont(name: "Courier New", size: UIFont.labelFontSize) as Any,
            ]
        case .listItem(style: _, depth: _):
            let paragraphStyle = self.paragraphStyle
            paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 16, options: [:])]
            paragraphStyle.defaultTabInterval = 16
            paragraphStyle.firstLineHeadIndent = 0
            paragraphStyle.headIndent = 16

            if !isLastSibling {
                paragraphStyle.paragraphSpacing = 0
            }

            return [
                .paragraphStyle: paragraphStyle,
            ]
        default:
            return nil
        }
    }

    public func replacement(for tag: Tag) -> NSAttributedString? {
        switch tag {
        case let .image(url):
            let attachment = ImageTextAttachment()
            attachment.image = self.imageLoader.load(for: url)
            let attachmentString = NSAttributedString(attachment: attachment)
            let attributedString = NSMutableAttributedString(attributedString: attachmentString)
            attributedString.append(NSAttributedString(string: "\n"))
            return attributedString
        default:
            return nil
        }
    }

}
