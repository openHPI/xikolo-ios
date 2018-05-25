//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

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

    static func from(_ rawTag: RawTag, in context: Parser.Context) -> Tag? {
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
            guard let urlString = rawTag.attributes["href"] else { return nil }
            guard let url = URL(string: urlString) else { return nil }
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
            guard let (style, depth) = context.currentListItemContext else { return nil }
            return .listItem(style: style, depth: depth)
        case "br":
            return .newline
        case "p":
            return .paragraph
        default:
            return nil
        }
    }

    func hasSameType(as other: Tag) -> Bool {
        switch (self, other) {
        case (.headline1, .headline1): return true
        case (.headline2, .headline2): return true
        case (.headline3, .headline3): return true
        case (.headline4, .headline4): return true
        case (.headline5, .headline5): return true
        case (.headline6, .headline6): return true
        case (.link(url: _), .link(url: _)): return true
        case (.image(url: _), .image(url: _)): return true
        case (.bold, .bold): return true
        case (.italic, .italic): return true
        case (.code, .code): return true
        case (.orderedList, .orderedList): return true
        case (.unorderedList, .unorderedList): return true
        case (.listItem(style: _, depth: _), .listItem(style: _, depth: _)): return true
        case (.newline, .newline): return true
        case (.paragraph, .paragraph): return true
        default:
            return false
        }
    }

    func modifyDetection(_ detection: Detection) -> Detection {
        var detection = detection

        if case .listItem(style: _, depth: _) = detection.type, self.hasSameType(as: .unorderedList) ||  self.hasSameType(as: .orderedList) {
            detection.isLastSibling = true
        }

        return detection
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
        case let .listItem(style: style, depth: depth):
            let indent = String(repeating: "\t", count: depth)

            let symbol: String
            if case let .ordered(position: position) = style {
                symbol = String(position) + "." // XXX: 1. -> i. -> a. -> a.
            } else {
                switch depth {
                case 0: symbol = "•"
                case 1: symbol = "◦"
                default: symbol = "■"
                }
            }

            return indent + symbol + "\t"
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
        self.isLastSibling = false
    }
}

public struct Parser {

    struct Context {
        private(set) var tagStack: [(rawTag: RawTag, index: String.Index)] = []
        private var listItemCounter: [Int] = []

        mutating func add(_ rawTag: RawTag, at index: String.Index) {
            self.tagStack.append((rawTag, index))
            if ["ul", "ol"].contains(rawTag.name) {
                self.listItemCounter.append(0)
            } else if rawTag.name == "li" {
                let index = self.listItemCounter.count - 1
                let newValue = self.listItemCounter[index] + 1
                self.listItemCounter[index] = newValue
            }
        }

        mutating func removeRawTag(with name: String, at index: Int) {
            self.tagStack.remove(at: index)
            if ["ul", "ol"].contains(name) {
                let index = self.listItemCounter.count - 1
                self.listItemCounter.remove(at: index)
            }
        }

        var currentListItemContext: (ListItemStyle, Int)? {
            let lists = self.tagStack.map { $0.rawTag.name }.filter { $0 == "ol" || $0 == "ul" }
            let depth = lists.count - 1
            switch lists.last {
            case "ol":
                let position = (self.listItemCounter.last ?? 0) + 1
                return (.ordered(position: position), depth)
            case "ul":
                return (.unordered, depth)
            default:
                return nil
            }
        }

    }

    public init() {}

    public var styleCollection: StyleCollection?

    public func attributedString(for html: String) -> NSMutableAttributedString {
        let singleLineHtml = html.replacingOccurrences(of: "\n", with: "")
        let (transformedHtml, detections) = self.detectAndTransformTags(in: singleLineHtml)
        let attributedHtml = NSMutableAttributedString(string: transformedHtml)

        guard let styleCollection = self.styleCollection else {
            return attributedHtml.trimmedAttributedString(set: .whitespacesAndNewlines)
        }

        attributedHtml.addAttributes(styleCollection.baseStyle, range: NSRange(location: 0, length: attributedHtml.length))

        for detection in detections.reversed() {
            if let attributes = styleCollection.style(for: detection.type, isLastSibling: detection.isLastSibling) {
                attributedHtml.addAttributes(attributes, range: NSRange(detection.range, in: transformedHtml))
            }

            if let replacement = styleCollection.replacement(for: detection.type) {
                attributedHtml.replaceCharacters(in: NSRange(detection.range, in: transformedHtml), with: replacement)
            }
        }

        // This has to be done on the NSAttributedString in order to prevent out of bounds detections
        return attributedHtml.trimmedAttributedString(set: .whitespacesAndNewlines)
    }

    func detectAndTransformTags(in html: String) -> (String, [Detection]) {
        let scanner = Scanner(string: html)
        scanner.charactersToBeSkipped = nil
        var resultString: String = ""

        var previousDetection: Detection?

        var detections: [Detection] = []
        var parseContext = Context()

        while !scanner.isAtEnd {
            if let textString = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "<&")) {
                resultString += textString
            } else {
                if scanner.scanString("<") != nil {
                    let isStartTag = scanner.scanString("/") == nil
                    if let tagString = scanner.scanUpTo(">") {
                        if let rawTag = self.parseTag(tagString, isStartTag: isStartTag, context: parseContext) {
                            let tag = Tag.from(rawTag, in: parseContext)

                            var resultTextEndIndex = resultString.endIndex

                            if let tag = tag, let textString = isStartTag ? tag.prefix : tag.suffix {
                                resultString += textString
                            }

                            if !isStartTag {
                                resultTextEndIndex = resultString.endIndex
                            }

                            if let tag = tag, !tag.hasEndTag {
                                if let previousDetection = previousDetection {
                                    detections.append(previousDetection)
                                }

                                previousDetection = Detection(type: tag, range: resultTextEndIndex..<resultTextEndIndex)
                            } else if isStartTag {
                                parseContext.add(rawTag, at: resultTextEndIndex)
                            } else {
                                for (index, tagStackItem) in parseContext.tagStack.enumerated().reversed() {
                                    if tagStackItem.rawTag.name == rawTag.name, let newTag = Tag.from(tagStackItem.rawTag, in: parseContext) {
                                        if let previousDetection = previousDetection {
                                            let modifiedDetection = newTag.modifyDetection(previousDetection)
                                            detections.append(modifiedDetection)
                                        }

                                        previousDetection = Detection(type: newTag, range: tagStackItem.index..<resultTextEndIndex)
                                        parseContext.removeRawTag(with: rawTag.name, at: index)
                                        break
                                    }
                                }

                            }
                        }
                        scanner.scanString(">")
                    } else {
                        continue
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

        if var previousDetection = previousDetection {
            previousDetection.isLastSibling = true
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
