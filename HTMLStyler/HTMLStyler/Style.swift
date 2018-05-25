//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public typealias Style = [NSAttributedStringKey: Any]

public protocol StyleCollection {

    var baseStyle: Style { get }

    func style(for tag: Tag, isLastSibling: Bool) -> Style?

    func replacement(for tag: Tag) -> NSAttributedString?

}

public extension StyleCollection {

    var baseStyle: Style {
        return [:]
    }

    func style(for tag: Tag, isLastSibling: Bool) -> Style? {
        return nil
    }

    func replacement(for tag: Tag) -> NSAttributedString? {
        return nil
    }

}

public struct DefaultStyleCollection: StyleCollection {

    let tintColor: UIColor

    public init(tintColor: UIColor) {
        self.tintColor = tintColor
    }

    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        paragraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        return paragraphStyle
    }

    public var baseStyle: Style {
        return [
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
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
//            guard let data = try? Data(contentsOf: url) else { return nil }
//            guard let image = UIImage(data: data) else { return nil }
//            let attachment = ImageTextAttachment()
//            attachment.image = image

            let attachment = ImageTextAttachment()
            attachment.image = self.testImage

            let attachmentString = NSAttributedString(attachment: attachment)
            let attributedString = NSMutableAttributedString(attributedString: attachmentString)
            attributedString.append(NSAttributedString(string: "\n"))
            return attributedString
        default:
            return nil
        }
    }

    private var testImage: UIImage? {
        let rect = CGRect(origin: .zero, size: CGSize(width: 200, height: 75))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        self.tintColor.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }

        return UIImage(cgImage: cgImage)
    }

}

class ImageTextAttachment: NSTextAttachment {

    override func attachmentBounds(for textContainer: NSTextContainer?,
                          proposedLineFragment lineFrag: CGRect,
                          glyphPosition position: CGPoint,
                          characterIndex charIndex: Int) -> CGRect {
        guard let image = self.image, image.size.width != 0, image.size.height != 0 else { return CGRect.zero }

        let scalingFactor = min(1, lineFrag.width / image.size.width)
        return CGRect(x: 0, y: 0, width: image.size.width * scalingFactor, height: image.size.height * scalingFactor)
    }

}
