//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Down

extension DownStylerConfiguration {

    static func makeDynamicConfiguration() -> DownStylerConfiguration {
        return DownStylerConfiguration(
            fonts: Self.dynamicFontCollection,
            colors: Self.dynamicColors
        )
    }

    private static var dynamicFontCollection: StaticFontCollection {
        return StaticFontCollection(
            heading1: Self.makeDynamicFont(for: .systemFont(ofSize: UIFont.labelFontSize * 1.30, weight: .bold)),
            heading2: Self.makeDynamicFont(for: .systemFont(ofSize: UIFont.labelFontSize * 1.25, weight: .bold)),
            heading3: Self.makeDynamicFont(for: .systemFont(ofSize: UIFont.labelFontSize * 1.20, weight: .bold)),
            heading4: Self.makeDynamicFont(for: .systemFont(ofSize: UIFont.labelFontSize * 1.15, weight: .bold)),
            heading5: Self.makeDynamicFont(for: .systemFont(ofSize: UIFont.labelFontSize * 1.10, weight: .bold)),
            heading6: Self.makeDynamicFont(for: .systemFont(ofSize: UIFont.labelFontSize * 1.05, weight: .bold)),
            body: .preferredFont(forTextStyle: .body),
            code: Self.dynamicCodeFont,
            listItemPrefix: Self.makeDynamicFont(for: DownFont.monospacedDigitSystemFont(ofSize: UIFont.labelFontSize * 1.0, weight: .regular))
        )
    }

    private static var dynamicCodeFont: DownFont {
        if #available(iOS 13, *) {
            return .monospacedSystemFont(ofSize: UIFont.labelFontSize, weight: .regular)
        } else if let menlo = UIFont(name: "menlo", size: UIFont.labelFontSize) {
            return menlo
        } else if let courierNew = UIFont(name: "Courier New", size: UIFont.labelFontSize) {
            return courierNew
        } else {
            return .systemFont(ofSize: UIFont.labelFontSize)
        }
    }

    private static func makeDynamicFont(for font: UIFont) -> UIFont {
        if #available(iOS 11, *) {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        } else {
            return font
        }
    }

    private static var dynamicColors: ColorCollection {
        if #available(iOS 13, *) {
            return StaticColorCollection(
                heading1: .label,
                heading2: .label,
                heading3: .label,
                body: .label,
                code: .label,
                link: Brand.default.colors.window,
                quote: .secondaryLabel,
                quoteStripe: .secondaryLabel,
                thematicBreak: .separator,
                listItemPrefix: .tertiaryLabel,
                codeBlockBackground: .secondarySystemBackground
            )
        } else {
            return StaticColorCollection()
        }
    }

}
