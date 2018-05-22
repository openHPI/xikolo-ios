//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

import UIKit

//let testHtml = """
//<h1>Headline level 1</h1>
//<h2>Headline level 2</h2>
//<h3>Headline level 3</h3>
//<h4>Headline level 4</h4>
//<h5>Headline level 5</h5>
//<h6>Headline level 6</h6>
//<p>This is a normal paragraph.</p>
//<b>This is bold text.</b>
//<i>This is italic text.</i>
//
//<code>Some code 123</code>
//<pre>some more code</pre>
//
//<a href="https://open.hpi.de">This is a link to openHPI.</a>
//Following just the url: https://google.com
//
//<ul>
//<li>unordered list item 1 level 1</li>
//<li>unordered list item 2 level 1</li><li>unordered list item 3 level 1</li>
//<li>unordered list item 4 level 1</li>
//</ul>
//
//<ol>
//<li>ordered list item 1 level 1</li>
//<li>ordered list item 2 level 1</li><li>ordered list item 3 level 1</li>
//<li>ordered list item 4 level 1</li>
//</ol>
//
//
//<ul>
//<li>unordered list item 1 level 1</li>
//<li>
//    <ul>
//        <li>unordered list item 1 level 1</li>
//        <li>unordered list item 2 level 2</li>
//    </ul>
//</li>
//<li>unordered list item 2 level 1</li><li>unordered list item 3 level 1</li>
//<li>unordered list item 4 level 1</li>
//</ul>
//
//todo:
//- image small
//- image large
//- image svg
//"""

let testHtml = """
<a href="https://open.hpi.de">This is a link to openHPI.</a>
Following just the url: https://google.com
"""

enum ListItemStyle: Hashable {
    case unordered
    case ordered(position: Int)
}

struct TagInfo {
    let name: String
    let attributes: [String: String]

    var isSingleTag: Bool {
        return ["img", "br"].contains(self.name)
    }
}

enum Tag: Hashable {
    case headline1
    case headline2
    case headline3
    case headline4
    case headline5
    case headline6
    case link(url: URL)
    case image(url: URL)
    case bold
    case italic
    case code
    //    case orderedList
    //    case unorderedList
    case listItem(style: ListItemStyle, depth: Int)
    case newline

    static func from(_ tagInfo: TagInfo) -> Tag? {
        switch tagInfo.name {
        case "h1":
            return .headline1
        case "h2":
            return .headline2
        case "h3":
            return .headline3
        case "h4":
            return .headline4
        case "h5":
            return .headline5
        case "h6":
            return .headline6
        case "a":
            guard let urlString = tagInfo.attributes["href"] else {
                print("no href: \(tagInfo.attributes)")
                return nil
            }

            guard let url = URL(string: urlString) else {
                print("no real url")
                return nil
            }
            return .link(url: url)
        case "img":
            guard let urlString = tagInfo.attributes["src"], let url = URL(string: urlString) else { return nil }
            return .image(url: url)
        case "b":
            return .bold
        case "i":
            return .italic
        case "code", "pre":
            return .code
        case "li":
            let style = ListItemStyle.unordered
            return .listItem(style: style, depth: 0) // XXX: implement
        case "br":
            return .newline
        default:
            return nil
        }
    }

    //    var attributes: [NSAttributedStringKey: Any] {
    //        switch self {
    //        case let .link(url):
    //            return [.link: url]
    //        case .image(_):
    //            return [.attachment: UIImage()]
    //        default:
    //            return [:]
    //        }
    //    }

    var prefix: String? {
        switch self {
        case .newline:
            return "\n"
        case let .listItem(style: style, depth: _):
            if case let .ordered(position: position) = style {
                return String(position) + ". " // XXX: 1. -> i. -> a. -> a.
            } else {
                return "- " // XXX:  bullet filled -> bullet outline -> square filled -> square filled
            }
        default:
            return nil
        }
    }

    var suffix: String? {
        switch self {
        case .listItem(style: _, depth: _):
            return "\n" // XXX we only need this if list items are in one line
        default:
            return nil
        }
    }
}

struct Detection {
    let type: Tag
    let range: Range<String.Index>
}

extension Scanner {

    // MARK: Strings

    /// Returns a string, scanned as long as characters from a given character set are encountered, or `nil` if none are found.
    func scanCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanCharacters(from: set, into: &value) {
            return value as String?
        }
        return nil
    }

    /// Returns a string, scanned until a character from a given character set are encountered, or the remainder of the scanner's string. Returns `nil` if the scanner is already `atEnd`.
    func scanUpToCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanUpToCharacters(from: set, into: &value) {
            return value as String?
        }
        return nil
    }

    /// Returns the given string if scanned, or `nil` if not found.
    @discardableResult func scanString(_ str: String) -> String? {
        var value: NSString? = ""
        if scanString(str, into: &value) {
            return value as String?
        }
        return nil
    }

    /// Returns a string, scanned until the given string is found, or the remainder of the scanner's string. Returns `nil` if the scanner is already `atEnd`.
    func scanUpTo(_ str: String) -> String? {
        var value: NSString? = ""
        if scanUpTo(str, into: &value) {
            return value as String?
        }
        return nil
    }

    // MARK: Numbers

    /// Returns a Double if scanned, or `nil` if not found.
    func scanDouble() -> Double? {
        var value = 0.0
        if scanDouble(&value) {
            return value
        }
        return nil
    }

    /// Returns a Float if scanned, or `nil` if not found.
    func scanFloat() -> Float? {
        var value: Float = 0.0
        if scanFloat(&value) {
            return value
        }
        return nil
    }

    /// Returns an Int if scanned, or `nil` if not found.
    func scanInteger() -> Int? {
        var value = 0
        if scanInt(&value) {
            return value
        }
        return nil
    }

    /// Returns an Int32 if scanned, or `nil` if not found.
    func scanInt() -> Int32? {
        var value: Int32 = 0
        if scanInt32(&value) {
            return value
        }
        return nil
    }

    /// Returns an Int64 if scanned, or `nil` if not found.
    func scanLongLong() -> Int64? {
        var value: Int64 = 0
        if scanInt64(&value) {
            return value
        }
        return nil
    }

    /// Returns a UInt64 if scanned, or `nil` if not found.
    func scanUnsignedLongLong() -> UInt64? {
        var value: UInt64 = 0
        if scanUnsignedLongLong(&value) {
            return value
        }
        return nil
    }

    /// Returns an NSDecimal if scanned, or `nil` if not found.
    func scanDecimal() -> Decimal? {
        var value = Decimal()
        if scanDecimal(&value) {
            return value
        }
        return nil
    }

    // MARK: Hex Numbers

    /// Returns a Double if scanned in hexadecimal, or `nil` if not found.
    func scanHexDouble() -> Double? {
        var value = 0.0
        if scanHexDouble(&value) {
            return value
        }
        return nil
    }

    /// Returns a Float if scanned in hexadecimal, or `nil` if not found.
    func scanHexFloat() -> Float? {
        var value: Float = 0.0
        if scanHexFloat(&value) {
            return value
        }
        return nil
    }

    /// Returns a UInt32 if scanned in hexadecimal, or `nil` if not found.
    func scanHexInt() -> UInt32? {
        var value: UInt32 = 0
        if scanHexInt32(&value) {
            return value
        }
        return nil
    }

    /// Returns a UInt64 if scanned in hexadecimal, or `nil` if not found.
    func scanHexLongLong() -> UInt64? {
        var value: UInt64 = 0
        if scanHexInt64(&value) {
            return value
        }
        return nil
    }
}


struct Parser {

    private struct Context {
        var tagStack: [(TagInfo, String.Index)] = []

    }

    private var customStyle: [NSAttributedStringKey: Any]?
    private var customStyles: [Tag: [NSAttributedStringKey: Any]] = [:]

    static var defaultStyle: [NSAttributedStringKey: Any] {
        return Style.defaultStyle
    }

    static func defaultStyle(for tag: Tag) -> [NSAttributedStringKey: Any] {
        return Style.defaultStyle(for: tag)
    }

    mutating func set(style: [NSAttributedStringKey: Any]) {
        self.customStyle = style
    }

    mutating func set(style: [NSAttributedStringKey: Any], for tag: Tag) {
        self.customStyles[tag] = style
    }

    func attributedString(for html: String) -> NSAttributedString {
        let (transformedHtml, detections) = self.detectAndTransformTags(in: html)
        let attributedHtml = NSMutableAttributedString(string: transformedHtml)

        var defaultAttributes = Style.defaultStyle

        for (key, value) in self.customStyle ?? [:] {
            defaultAttributes.updateValue(value, forKey: key)
        }

        attributedHtml.addAttributes(defaultAttributes, range: NSRange(location: 0, length: attributedHtml.length))

        for detection in detections {
            var attributes = Style.defaultStyle(for: detection.type)

            // apply custom styling attributes
            for (key, value) in self.customStyles[detection.type] ?? [:] {
                attributes.updateValue(value, forKey: key)
            }

            attributedHtml.addAttributes(attributes, range: NSRange(detection.range, in: transformedHtml))
        }

        return attributedHtml
    }

    func detectAndTransformTags(in html: String) -> (String, [Detection]) {
        let scanner = Scanner(string: html)
        scanner.charactersToBeSkipped = nil
        var resultString: String = ""
        var detections: [Detection] = []
        //        var tagStack: [(Tag, String.Index)] = []
        var parseContext = Context()

        while !scanner.isAtEnd {
            if let textString = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "<&")) {
                resultString += textString
            } else {
                if scanner.scanString("<") != nil {
                    let isStartTag = scanner.scanString("/") == nil
                    if let tagString = scanner.scanUpTo(">") {
                        if let tagInfo = self.parseTag(tagString, isStartTag: isStartTag, context: parseContext) {
                            let resultTextEndIndex = resultString.endIndex

                            //                            if let textString = isStartTag ? tag.prefix : tag.suffix {
                            //                                resultString += textString
                            //                            }

                            if tagInfo.isSingleTag {
                                if let tag = Tag.from(tagInfo) {
                                    let detection = Detection(type: tag, range: resultTextEndIndex..<resultTextEndIndex)
                                    detections.append(detection)
                                }
                            } else if isStartTag {
                                parseContext.tagStack.append((tagInfo, resultTextEndIndex))
                            } else {
                                for (index, (tagInfoInStack, startIndex)) in parseContext.tagStack.enumerated().reversed() {
                                    if tagInfoInStack.name == tagInfo.name, let tag = Tag.from(tagInfoInStack) {
                                        let detection = Detection(type: tag, range: startIndex..<resultTextEndIndex)
                                        detections.append(detection)
                                        parseContext.tagStack.remove(at: index)
                                        break
                                    }
                                }
                            }
                        }
                        scanner.scanString(">")
                    }
                } else if scanner.scanString("&") != nil {
                    if let specialString = scanner.scanUpTo(";") {
                        if let spec = Parser.specials[specialString] {
                            resultString += spec
                        }
                        scanner.scanString(";")
                    }
                }
            }
        }

        let detectedLinks = !detections.filter { if case .link(_) = $0.type { return true } else { return false }}.isEmpty
        print(detectedLinks)

        return (resultString, detections)
    }

    private static let specials = ["quot":"\"",
                                   "amp":"&",
                                   "apos":"'",
                                   "lt":"<",
                                   "gt":">"]

    private func parseTag(_ tagString: String, isStartTag: Bool, context: Context) -> TagInfo? {

        let tagScanner = Scanner(string: tagString)

        guard let tagName = tagScanner.scanCharacters(from: CharacterSet.alphanumerics) else {
            return nil
        }

        var attributes: [String: String] = [:]

        while isStartTag && !tagScanner.isAtEnd {

            guard let name = tagScanner.scanUpTo("=") else {
                break
            }

            print("attribute name: \(name)")

            guard tagScanner.scanString("=") != nil else {
                break
            }

            guard tagScanner.scanString("\"") != nil else {
                break
            }

            let value = tagScanner.scanUpTo("\"") ?? ""

            guard tagScanner.scanString("\"") != nil else {
                break
            }

            attributes[name] = value.replacingOccurrences(of: "&quot;", with: "\"")
            print("add attribute")
        }

        print("attribtues: \(attributes)")

        return TagInfo(name: tagName, attributes: attributes)
    }

}

extension Parser {
    private struct Style {
        static var defaultStyle: [NSAttributedStringKey: Any] {
            return [
                .font: UIFont.systemFont(ofSize: UIFont.systemFontSize)
            ] // XXX
        }

        static func defaultStyle(for tag: Tag) -> [NSAttributedStringKey: Any] {
            switch tag {
            case .headline1:
                return [
                    .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.65, weight: .bold) // + top and bottom spacing
                ]
            case .headline2:
                return [
                    .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.55, weight: .bold)
                ]
            case .headline3:
                return [
                    .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.45, weight: .bold)
                ]
            case .headline4:
                return [
                    .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.35, weight: .bold)
                ]
            case .headline5:
                return [
                    .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.25, weight: .bold)
                ]
            case .headline6:
                return [
                    .font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15, weight: .bold)
                ]
            case .bold:
                return [
                    .font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
                ]
            case .italic:
                return [
                    .font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)
                ]
            case let .link(url):
                return [
                    .font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                    .link: url,
                    .foregroundColor: UIColor.red,
                ]
            case .code:
                return [
                    .font: UIFont(name: "Courier New", size: UIFont.systemFontSize) as Any,//UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: .regular),
                    //                    .backgroundColor: UIColor.darkGray,
                    //                    .foregroundColor: UIColor.white,
                ]
            case .image(_):
                return [
                    .attachment: UIImage()
                ]
            default:
                return [:]
            }
        }
    }
}
//
//var parser = Parser()
////let style = Parser.defaultStyle(for: .headline1)
////parser.set(style: style, for: .headline1)
//let attributedString = parser.attributedString(for: testHtml)
//print(attributedString)


