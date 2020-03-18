//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

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

        var currentListItemContext: (ListItemType, Int)? {
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

    public func string(for html: String) -> String {
        let singleLineHtml = html.replacingOccurrences(of: "\n", with: " ")
        let (transformedHtml, _) = self.detectAndTransformTags(in: singleLineHtml)
        return transformedHtml
    }

    public func attributedString(for html: String) -> NSMutableAttributedString {
        let singleLineHtml = html.replacingOccurrences(of: "\n", with: " ")
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
                if !textString.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                    resultString += textString
                }
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
