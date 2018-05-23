//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest
@testable import HTMLStyler

class HTMLStylerTests: XCTestCase {

    private struct BaseStyleCollection: StyleCollection {
        let baseStyle: Style = [.foregroundColor: UIColor.red]
    }

    private struct BoldStyleCollection: StyleCollection {
        func style(for tag: Tag, isLastSibling: Bool) -> Style? {
            return [.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)]
        }
    }

    private struct BoldAndItalicStyleCollection: StyleCollection {
        func style(for tag: Tag, isLastSibling: Bool) -> Style? {
            if case .italic = tag {
                return [.font: UIFont.italicSystemFont(ofSize: UIFont.labelFontSize)]
            } else {
                return [.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)]
            }
        }
    }

    private struct LinkStyleCollection: StyleCollection {
        func style(for tag: Tag, isLastSibling: Bool) -> Style? {
            guard case let .link(url) = tag else { return nil }
            return [
                .font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
                .link: url,
            ]
        }
    }

    func testEmpty() {
        let parser = Parser()

        let testHTML = "Hello World!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")

        XCTAssertEqual(test, reference)
    }

    func testBase() {
        var parser = Parser()
        parser.styleCollection = BaseStyleCollection()

        let testHTML = "Hello World!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(parser.styleCollection!.baseStyle, range: NSRange(location: 0, length: 14))

        XCTAssertEqual(test, reference)
    }

    func testManyTags() {
        var parser = Parser()
        parser.styleCollection = BoldAndItalicStyleCollection()

        let testHTML = "He<i>llo</i> <b>World</b>!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .italic, isLastSibling: true)!, range: NSRange(location: 2, length: 3))
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 6, length: 5))

        XCTAssertEqual(test, reference)
    }

    func testManySameTags() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "He<b>llo</b> <b>World</b>!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 2, length: 3))
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 6, length: 5))

        XCTAssertEqual(test, reference)
    }

    func testTagsNested() {
        var parser = Parser()
        parser.styleCollection = BoldAndItalicStyleCollection()

        let testHTML = "Hello <b>W<i>orld</i>!!!</b>"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 6, length: 1))
        reference.addAttributes(parser.styleCollection!.style(for: .italic, isLastSibling: true)!, range: NSRange(location: 7, length: 4))
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 11, length: 3))

        XCTAssertEqual(test, reference)
    }

    func testNotClosedTag() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Hello <b>World!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")

        XCTAssertEqual(test, reference)
    }

    func testNotOpenedTag() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Hello </b>World!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")

        XCTAssertEqual(test, reference)
    }

    func testIncompleteTag() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Hello <World!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello <World!!!")

        XCTAssertEqual(test, reference)
    }

    func testBold() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Hello <b>World</b>!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 6, length: 5))

        XCTAssertEqual(test, reference)
    }

    func testParagraph() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "<p>Hello</p>World!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello\nWorld!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 0, length: 6))

        XCTAssertEqual(test, reference)
    }

    func testNewLine() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Hello<br>World!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSAttributedString(string: "Hello\nWorld!!!")

        XCTAssertEqual(test, reference)
    }

    func testNewLine2() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Hello<br />World!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSAttributedString(string: "Hello\nWorld!!!")

        XCTAssertEqual(test, reference)
    }

    func testHTMLLinks() {
        var parser = Parser()
        parser.styleCollection = LinkStyleCollection()

        let testHTML = "Link to <a href=\"http://google.com\">Google</a>"
        let test = parser.attributedString(for: testHTML)

        let tag = Tag.link(url: URL(string: "http://google.com")!)
        let reference = NSMutableAttributedString(string: "Link to Google")
        reference.addAttributes(parser.styleCollection!.style(for: tag, isLastSibling: true)!, range: NSRange(location: 8, length: 6))

        XCTAssertEqual(test, reference)
    }

/*
    func testUnorderedList() {
        let testHTML = """
        <p>List:</p>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
        </ul>
        <p>New paragraph</p>
        """

        let test = self.parser.attributedString(for: testHTML)

        let referenceText = """
        List:
        - Item 1
        - Item 2
        New paragraph
        """
        let reference = NSMutableAttributedString(string: referenceText)

        let listItemParagraphStyle = NSMutableParagraphStyle()
        listItemParagraphStyle.lineHeightMultiple = 1.15
        listItemParagraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        listItemParagraphStyle.paragraphSpacing = 0
        listItemParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 16, options: [:])]
        listItemParagraphStyle.defaultTabInterval = 16
        listItemParagraphStyle.firstLineHeadIndent = 0
        listItemParagraphStyle.headIndent = 16

        let noSpacingParagraphStyle = NSMutableParagraphStyle()
        noSpacingParagraphStyle.lineHeightMultiple = 1.15
        noSpacingParagraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        noSpacingParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 16, options: [:])]
        noSpacingParagraphStyle.defaultTabInterval = 16
        noSpacingParagraphStyle.firstLineHeadIndent = 0
        noSpacingParagraphStyle.headIndent = 16

        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 6))
        reference.addAttributes([
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            .paragraphStyle: listItemParagraphStyle,
        ], range: NSRange(location: 6, length: 9))
        reference.addAttributes([
            .paragraphStyle: noSpacingParagraphStyle,
        ], range: NSRange(location: 15, length: 9))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 24, length: 13))

        XCTAssertEqual(test, reference)
    }

    func testNestedUnorderedLists() {
        XCTFail("Implement")
    }

    func testOrderedLists() {
        let testHTML = """
        <p>List:</p>
        <ol>
            <li>Item 1</li>
            <li>Item 2</li>
        </ol>
        <p>New paragraph</p>
        """

        let test = self.parser.attributedString(for: testHTML)

        let referenceText = """
        List:
        1. Item 1
        2. Item 2
        New paragraph
        """
        let reference = NSMutableAttributedString(string: referenceText)

        let listItemParagraphStyle = NSMutableParagraphStyle()
        listItemParagraphStyle.lineHeightMultiple = 1.15
        listItemParagraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        listItemParagraphStyle.paragraphSpacing = 0
        listItemParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 16, options: [:])]
        listItemParagraphStyle.defaultTabInterval = 16
        listItemParagraphStyle.firstLineHeadIndent = 0
        listItemParagraphStyle.headIndent = 16

        let noSpacingParagraphStyle = NSMutableParagraphStyle()
        noSpacingParagraphStyle.lineHeightMultiple = 1.15
        noSpacingParagraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        noSpacingParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 16, options: [:])]
        noSpacingParagraphStyle.defaultTabInterval = 16
        noSpacingParagraphStyle.firstLineHeadIndent = 0
        noSpacingParagraphStyle.headIndent = 16

        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 6))
        reference.addAttributes([
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            .paragraphStyle: listItemParagraphStyle,
        ], range: NSRange(location: 6, length: 10))
        reference.addAttributes([
            .paragraphStyle: noSpacingParagraphStyle,
        ], range: NSRange(location: 16, length: 10))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 26, length: 13))

        XCTAssertEqual(test, reference)
    }

    func testNestedOrderedLists() {
        XCTFail("Implement")
    }

    func testNestedMixedLists() {
        XCTFail("Implement")
    }

    func testTwoLists() {
        let testHTML = """
        <p>List:</p>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
        </ul>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
        </ul>
        <p>New paragraph</p>
        """

        let test = self.parser.attributedString(for: testHTML)

        let referenceText = """
        List:
        - Item 1
        - Item 2
        - Item 1
        - Item 2
        New paragraph
        """
        let reference = NSMutableAttributedString(string: referenceText)

        let listItemParagraphStyle = NSMutableParagraphStyle()
        listItemParagraphStyle.lineHeightMultiple = 1.15
        listItemParagraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        listItemParagraphStyle.paragraphSpacing = 0
        listItemParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 16, options: [:])]
        listItemParagraphStyle.defaultTabInterval = 16
        listItemParagraphStyle.firstLineHeadIndent = 0
        listItemParagraphStyle.headIndent = 16

        let noSpacingParagraphStyle = NSMutableParagraphStyle()
        noSpacingParagraphStyle.lineHeightMultiple = 1.15
        noSpacingParagraphStyle.paragraphSpacing = UIFont.labelFontSize / 3 * 2
        noSpacingParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 16, options: [:])]
        noSpacingParagraphStyle.defaultTabInterval = 16
        noSpacingParagraphStyle.firstLineHeadIndent = 0
        noSpacingParagraphStyle.headIndent = 16

        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 6))
        reference.addAttributes([
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            .paragraphStyle: listItemParagraphStyle,
        ], range: NSRange(location: 6, length: 9))
        reference.addAttributes([
            .paragraphStyle: noSpacingParagraphStyle,
        ], range: NSRange(location: 15, length: 9))
        reference.addAttributes([
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            .paragraphStyle: listItemParagraphStyle,
        ], range: NSRange(location: 24, length: 9))
        reference.addAttributes([
            .paragraphStyle: noSpacingParagraphStyle,
        ], range: NSRange(location: 33, length: 9))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 42, length: 13))

        XCTAssertEqual(test, reference)
    }
*/

    func testEmojis() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Hello <b>W🌎rld</b>!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello W🌎rld!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 6, length: 6))

        XCTAssertEqual(test,reference)
    }

    func testImages() {
        XCTFail("Implement")
    }

    func testDataDetectorLink() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Link to http://google.com"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Link to http://google.com")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 8, length: 17))

        XCTAssertEqual(test, reference)
    }

}
