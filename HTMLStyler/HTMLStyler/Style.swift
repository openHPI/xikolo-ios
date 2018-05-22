//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public typealias Style = [NSAttributedStringKey: Any]

//typealias TagStyle = (tagName: String, style: Style)
//typealias CheckingTypeStyle = (checkingType: NSTextCheckingResult.CheckingType, style: Style)
//struct Style {
//    let attributes: [NSAttributedStringKey: Any]
//
//    static var bold: Style {
//        return Style(attributes: [
//            .font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
//        ])
//    }
//
//}

public protocol StyleCollection {
    var baseStyle: Style { get }

    func style(for tag: Tag, isLastSibling: Bool) -> Style?
    func style(for checkingType: NSTextCheckingResult.CheckingType) -> Style?

}

public struct DefaultStyleCollection: StyleCollection {

    var tintColor: UIColor = .blue

    public init() {} // XXX

    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        paragraphStyle.paragraphSpacing = UIFont.labelFontSize / 2
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
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.48, weight: .bold), // + top and bottom spacing
                .paragraphStyle: paragraphStyle,
            ]
        case .headline2:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.40, weight: .bold)
            ]
        case .headline3:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.32, weight: .bold)
            ]
        case .headline4:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.24, weight: .bold)
            ]
        case .headline5:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.16, weight: .bold)
            ]
        case .headline6:
            return [
                .font: UIFont.systemFont(ofSize: UIFont.labelFontSize * 1.08, weight: .bold)
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
                .font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
                .link: url,
                .foregroundColor: self.tintColor,
            ]
        case .code:
            return [
                .font: UIFont(name: "Courier New", size: UIFont.labelFontSize) as Any,//UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: .regular),
                //                    .backgroundColor: UIColor.darkGray,
                //                    .foregroundColor: UIColor.white,
            ]
        case .image(_):
            return [
                .attachment: UIImage()
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
//        case .orderedList, .unorderedList:
//            let paragraphStyle = self.paragraphStyle
////            paragraphStyle.lineHeightMultiple = 0.1
////            paragraphStyle.lineSpacing = -80
////            paragraphStyle.paragraphSpacing = 16
//            return [
//                .paragraphStyle: paragraphStyle,
//            ]
        default:
            return nil
        }
    }

    public func style(for checkingType: NSTextCheckingResult.CheckingType) -> Style? {
        return [:]
    }

}
