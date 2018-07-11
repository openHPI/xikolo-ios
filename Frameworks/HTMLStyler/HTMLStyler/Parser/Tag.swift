//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

struct RawTag {
    let name: String
    let attributes: [String: String]
}

public enum ListItemType: Hashable {
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
    case listItem(style: ListItemType, depth: Int)
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
