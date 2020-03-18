//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct DefaultStyleCollection: StyleCollection {

    let tintColor: UIColor
    let imageLoader: ImageLoader.Type?

    public init(tintColor: UIColor, imageLoader: ImageLoader.Type? = nil) {
        self.tintColor = tintColor
        self.imageLoader = imageLoader
    }

    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        paragraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        return paragraphStyle
    }

    private func headingParagraphStyle(withScale scale: CGFloat) -> NSMutableParagraphStyle {
        let paragraphStyle = self.paragraphStyle
        paragraphStyle.paragraphSpacingBefore = UIFont.labelFontSize * scale / 3 * 2
        paragraphStyle.lineHeightMultiple = 1.15
        return paragraphStyle
    }

    private func headingStyle(withScale scale: CGFloat) -> Style {
        return [
            .font: self.makeDynamicFont(for: .systemFont(ofSize: UIFont.labelFontSize * scale, weight: .bold)),
            .paragraphStyle: self.headingParagraphStyle(withScale: scale),
        ]
    }

    public var baseStyle: Style {
        let foregroundColor: UIColor = {
            if #available(iOS 13, *) {
                return .label
            } else {
                return .black
            }
        }()

        return [
            .font: self.makeDynamicFont(for: .systemFont(ofSize: UIFont.labelFontSize)),
            .foregroundColor: foregroundColor,
            .paragraphStyle: self.paragraphStyle,
        ]
    }

    public func style(for tag: Tag, isLastSibling: Bool) -> Style? {
        switch tag {
        case .headline1:
            return self.headingStyle(withScale: 1.30)
        case .headline2:
            return self.headingStyle(withScale: 1.25)
        case .headline3:
            return self.headingStyle(withScale: 1.20)
        case .headline4:
            return self.headingStyle(withScale: 1.15)
        case .headline5:
            return self.headingStyle(withScale: 1.10)
        case .headline6:
            return self.headingStyle(withScale: 1.05)
        case .bold:
            return [
                .font: self.makeDynamicFont(for: .boldSystemFont(ofSize: UIFont.labelFontSize)),
            ]
        case .italic:
            return [
                .font: self.makeDynamicFont(for: .italicSystemFont(ofSize: UIFont.labelFontSize)),
            ]
        case let .link(url):
            return [
                .link: url,
                .foregroundColor: self.tintColor,
            ]
        case .code:
            let font: UIFont = {
                if #available(iOS 12, *) {
                    return .monospacedSystemFont(ofSize: UIFont.labelFontSize, weight: .regular)
                } else if let courierNew = UIFont(name: "Courier New", size: UIFont.labelFontSize) {
                    return courierNew
                } else {
                    return .systemFont(ofSize: UIFont.labelFontSize)
                }
            }()

            return [
                .font: self.makeDynamicFont(for: font),
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

    public func replacement(for tag: Tag, with layoutChangeHandler: (() -> Void)?) -> NSAttributedString? {
        switch tag {
        case let .image(url):
            guard let imageLoader = self.imageLoader else {
                return NSAttributedString(string: "\n")
            }

            let placeHolderColor: UIColor = {
                if #available(iOS 13, *) {
                    return .tertiarySystemFill
                } else {
                    return .lightGray
                }
            }()

            let placeHolderImage = UIImage.placeholder(withColor: placeHolderColor, size: CGSize(width: 2, height: 1))
            let attachment = AsyncImageTextAttachment(imageLoader: imageLoader, imageURL: url, layoutChangeHandler: layoutChangeHandler, placeHolderImage: placeHolderImage)
            let attachmentString = NSAttributedString(attachment: attachment)
            let attributedString = NSMutableAttributedString(attributedString: attachmentString)
            attributedString.append(NSAttributedString(string: "\n"))
            return attributedString
        default:
            return nil
        }
    }

    private func makeDynamicFont(for font: UIFont) -> UIFont {
        if #available(iOS 11, *) {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        } else {
            return font
        }
    }

}
