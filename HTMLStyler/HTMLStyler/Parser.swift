//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation




//struct Tag {
//
//    let name: String
//    let hasEndTag: Bool
//
//    // XXX:   var transformers
//
//}

public enum ListItemStyle: Hashable {
    case unordered
    case ordered(position: Int)
}

public enum Tag {
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
    case orderedList
    case unorderedList
    case listItem(style: ListItemStyle, depth: Int)
    case newline
    case paragraph

    static func from(_ rawTag: RawTag) -> Tag? {
        switch rawTag.name {
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
            guard let urlString = rawTag.attributes["href"] else {
                print("no href: \(rawTag.attributes)")
                return nil
            }

            guard let url = URL(string: urlString) else {
                print("no real url")
                return nil
            }
            return .link(url: url)
        case "img":
            guard let urlString = rawTag.attributes["src"], let url = URL(string: urlString) else { return nil }
            return .image(url: url)
        case "b", "strong":
            return .bold
        case "i", "em":
            return .italic
        case "code", "pre":
            return .code
        case "ul":
            return .unorderedList
        case "ol":
            return .orderedList
        case "li":
            let style = ListItemStyle.unordered
            return .listItem(style: style, depth: 0) // XXX: implement
        case "br":
            return .newline
        case "p":
            return .paragraph
        default:
            return nil
        }
    }

    var hasEndTag: Bool {
        switch self {
        case .image(url: _):
            return false
        case .newline:
            return false
        default:
            return true
        }
    }

    var prefix: String? {
        switch self {
        case .newline:
            return "\n"
        case let .listItem(style: style, depth: _):
            if case let .ordered(position: position) = style {
                return String(position) + ".\t" // XXX: 1. -> i. -> a. -> a.
            } else {
                return "-\t" // XXX:  bullet filled -> bullet outline -> square filled -> square filled
            }
        default:
            return nil
        }
    }

    var suffix: String? {
        switch self {
        case .listItem(style: _, depth: _):
            return "\n"
        case .paragraph:
            return "\n"
        case .headline1:
            return "\n"
        case .headline2:
            return "\n"
        case .headline3:
            return "\n"
        case .headline4:
            return "\n"
        case .headline5:
            return "\n"
        case .headline6:
            return "\n"
//        case .orderedList, .unorderedList:
//            return "\n"
        default:
            return nil
        }
    }
}


struct RawTag {
    let name: String
    let attributes: [String: String]
}

struct Detection {
    let type: Tag
    let range: Range<String.Index>
    var isLastSibling: Bool

    init(type: Tag, range: Range<String.Index>) {
        self.type = type
        self.range = range
        self.isLastSibling = true
    }
}

public struct Parser {

    private struct Context {
        private(set) var tagStack: [(rawTag: RawTag, index: String.Index)] = []

        mutating func add(_ rawTag: RawTag, at index: String.Index) {
            self.tagStack.append((rawTag, index))
        }

        mutating func removeRawTag(at index: Int) {
            self.tagStack.remove(at: index)
        }

        var inListContext: Bool {
            guard let lastTagName = self.tagStack.last?.rawTag.name else { return false }
            return ["ul", "ol"].contains(lastTagName)
        }
    }

    public init() {}

    public var styleCollection: StyleCollection?

    public func attributedString(for html: String) -> NSMutableAttributedString {
        let singleLineHtml = html.replacingOccurrences(of: "\n", with: "")
        let (transformedHtml, detections) = self.detectAndTransformTags(in: singleLineHtml)
        let attributedHtml = NSMutableAttributedString(string: transformedHtml)
//
//        var defaultAttributes = Style.defaultStyle
//
//        for (key, value) in self.customStyle ?? [:] {
//            defaultAttributes.updateValue(value, forKey: key)
//        }
//
        guard let styleCollection = self.styleCollection else {
            return attributedHtml
        }

        attributedHtml.addAttributes(styleCollection.baseStyle, range: NSRange(location: 0, length: attributedHtml.length))

        for detection in detections.reversed() {
            if let attributes = styleCollection.style(for: detection.type, isLastSibling: detection.isLastSibling) {
                attributedHtml.addAttributes(attributes, range: NSRange(detection.range, in: transformedHtml))
            }
        }

        return attributedHtml
    }

    func detectAndTransformTags(in html: String) -> (String, [Detection]) {
        let scanner = Scanner(string: html)
        scanner.charactersToBeSkipped = nil
        var resultString: String = ""

        var previousDetection: Detection?

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
                        if let rawTag = self.parseTag(tagString, isStartTag: isStartTag, context: parseContext) {
                            let tag = Tag.from(rawTag)

                            if let tag = tag, let textString = isStartTag ? tag.prefix : tag.suffix {
                                resultString += textString
                            }

                            let resultTextEndIndex = resultString.endIndex

                            if let tag = tag, !tag.hasEndTag {
                                if let previousDetection = previousDetection {
                                    detections.append(previousDetection)
                                }

                                previousDetection = Detection(type: tag, range: resultTextEndIndex..<resultTextEndIndex)
                            } else if isStartTag {
                                parseContext.add(rawTag, at: resultTextEndIndex)
                            } else {
                                for (index, tagStackItem) in parseContext.tagStack.enumerated().reversed() {
                                    if tagStackItem.rawTag.name == rawTag.name, let tag = Tag.from(tagStackItem.rawTag) {
                                        if var previousDetection = previousDetection {
                                            previousDetection.isLastSibling = false
                                            detections.append(previousDetection)
                                        }

                                        previousDetection = Detection(type: tag, range: tagStackItem.index..<resultTextEndIndex)
                                        parseContext.removeRawTag(at: index)
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

        if let previousDetection = previousDetection {
            detections.append(previousDetection)
        }

        return (resultString, detections)
    }

    private static let specials = [
        "quot":"\"",
        "amp":"&",
        "apos":"'",
        "lt":"<",
        "gt":">",
    ]

    private func parseTag(_ tagString: String, isStartTag: Bool, context: Context) -> RawTag? {

        let tagScanner = Scanner(string: tagString)

        guard let tagName = tagScanner.scanCharacters(from: CharacterSet.alphanumerics) else {
            return nil
        }

        var attributes: [String: String] = [:]

        while isStartTag && !tagScanner.isAtEnd {

            guard let name = tagScanner.scanUpTo("=") else {
                break
            }

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
        }

        return RawTag(name: tagName, attributes: attributes)
    }

}
