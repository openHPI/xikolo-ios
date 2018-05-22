//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest
@testable import HTMLStyler

//class HTMLStylerTests: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}

class HTMLStylerTests: XCTestCase {

    private let parser: Parser = {
        var parser = Parser()
        parser.styleCollection = DefaultStyleCollection()
        return parser
    }()

    private let defaultParagraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        paragraphStyle.paragraphSpacing = UIFont.labelFontSize / 2
        return paragraphStyle
    }()

    private let defaultStyle: Style = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        paragraphStyle.paragraphSpacing = UIFont.labelFontSize / 2
        return [
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            .paragraphStyle: paragraphStyle,
        ]
    }()

    private let defaultBoldStyle: Style = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        paragraphStyle.paragraphSpacing = UIFont.labelFontSize / 2
        return [
            .font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            .paragraphStyle: paragraphStyle,
        ]
    }()

    func testBase() {
        let testHTML = "Hello World!!!"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(self.defaultStyle, range: NSMakeRange(0, 14))

        XCTAssertEqual(test, reference)
    }

    func testBold() {
        let testHTML = "Hello <b>World</b>!!!"
        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 6))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 6, length: 5))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 11, length: 3))

        XCTAssertEqual(test, reference)
    }

    func testParagrpahs() {
        let testHTML = "<p>Hello</p><p>World!!!</p>"
        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello\nWorld!!!\n")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 6))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 6, length: 9))

        XCTAssertEqual(test, reference)
    }

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




//    func testTagOverMutilpleLines() {
//
////        let test = "<b>Hello\nWorld</b>!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45)))
////            .styleAll(.font(.systemFont(ofSize: 12)))
////            .attributedString
//
//        let testHTML = "<b>Hello\nWorld</b>!!!"
//
//        let test = self.parser.attributedString(for: testHTML)
//
//        let reference = NSMutableAttributedString(string: "Hello\nWorld!!!")
//        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 0, length: 11))
//        reference.addAttributes(self.defaultStyle, range: NSRange(location: 11, length: 3))
//
//        XCTAssertEqual(test, reference)
//    }

//    func testParams() {
//        let a = "<a href=\"http://google.com\">Hello</a> World!!!".style()
//
//        let reference = NSMutableAttributedString(string: "Hello World!!!")
//
//        XCTAssertEqual(a.attributedString, reference)
//
//        XCTAssertEqual(a.detections[0].range, a.string.startIndex..<a.string.index(a.string.startIndex, offsetBy: 5))
//
//        if case .tag(let tag) = a.detections[0].type {
//            XCTAssertEqual(tag.name, "a")
//            XCTAssertEqual(tag.attributes, ["href":"http://google.com"])
//
//        }
//
//    }

    func testManyTags() {
        let testHTML = "He<i>llo</i> <b>World</b>!!!"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 2))
        reference.addAttributes([
            .font: UIFont.italicSystemFont(ofSize: UIFont.labelFontSize),
            .paragraphStyle: self.defaultParagraphStyle,
        ], range: NSRange(location: 2, length: 3))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 5, length: 1))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 6, length: 5))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 11, length: 3))

        XCTAssertEqual(test, reference)
    }

    func testManySameTags() {
        let testHTML = "He<b>llo</b> <b>World</b>!!!"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 2))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 2, length: 3))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 5, length: 1))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 6, length: 5))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 11, length: 3))

        XCTAssertEqual(test, reference)
    }

    func testTagsNested() {
        let testHTML = "Hello <b>W<i>orld</i>!!!</b>"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 6))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 6, length: 1))
        reference.addAttributes([
            .font: UIFont.italicSystemFont(ofSize: UIFont.labelFontSize),
            .paragraphStyle: self.defaultParagraphStyle,
        ], range: NSRange(location: 7, length: 4))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 11, length: 3))

        XCTAssertEqual(test, reference)
    }

    func testNewLine() {
//        let test = "Hello<br>World!!!".style(tags: []).attributedString

        let testHTML = "Hello<br>World!!!"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSAttributedString(string: "Hello\nWorld!!!", attributes: self.defaultStyle)

        XCTAssertEqual(test, reference)
    }

    func testNotClosedTag() {
//        let test = "Hello <b>World!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45))).attributedString

        let testHTML = "Hello <b>World!!!"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 14))

        XCTAssertEqual(test, reference)
    }

    func testNotOpenedTag() {
//        let test = "Hello </b>World!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45))).attributedString

        let testHTML = "Hello </b>World!!!"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello World!!!")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 14))

        XCTAssertEqual(test, reference)
    }

    func testIncompleteTag() {
//        let test = "Hello <World!!!".style(tags: Style("b").font(.boldSystemFont(ofSize: 45))).attributedString

        let testHTML = "Hello <World!!!"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello <World!!!")

        XCTAssertEqual(test, reference)
    }

//    func testHashCodes() {
//        let test = "#Hello @World!!!"
//            .styleHashtags(Style.font(.boldSystemFont(ofSize: 45)))
//            .styleMentions(Style.foregroundColor(.red))
//            .attributedString
//
//        let reference = NSMutableAttributedString(string: "#Hello @World!!!")
//        reference.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 45)], range: NSMakeRange(0, 6))
//        reference.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], range: NSMakeRange(7, 6))
//
//        XCTAssertEqual(test, reference)
//    }

//    func testDataDetectorPhoneRaw() {
//
//        let test = "Call me (888)555-5512".style(textCheckingTypes: [.phoneNumber],
//                                                 style: Style.font(.boldSystemFont(ofSize: 45)))
//            .attributedString
//
//        let reference = NSMutableAttributedString(string: "Call me (888)555-5512")
//        reference.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 45)], range: NSMakeRange(8, 13))
//
//        XCTAssertEqual(test, reference)
//    }

    func testDataDetectorLinkRaw() {
//        let test = "Check this http://google.com".style(textCheckingTypes: [.link],
//                                                        style: Style.font(.boldSystemFont(ofSize: 45)))
//            .attributedString

        let testHTML = "Check this http://google.com"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Check this http://google.com")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 11))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 11, length: 17))

        XCTAssertEqual(test, reference)
    }

//    func testDataDetectorPhone() {
//        let test = "Call me (888)555-5512".stylePhoneNumbers(Style.font(.boldSystemFont(ofSize: 45)))
//            .attributedString
//
//        let reference = NSMutableAttributedString(string: "Call me (888)555-5512")
//        reference.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 45)], range: NSMakeRange(8, 13))
//
//        XCTAssertEqual(test, reference)
//    }

    func testHTMLLinks() {
        let testHTML = "Link to <a href=\"http://google.com\">Google</a>"
        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Link to Google")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 8))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 8, length: 6))
        reference.addAttributes([
            .link: URL(string: "http://google.com")!,
            .foregroundColor: UIColor.blue,
        ], range: NSRange(location: 8, length: 6))

        XCTAssertEqual(test, reference)
    }

    func testDataDetectorLink() {
        let testHTML = "Link to http://google.com"
        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Link to http://google.com")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 8))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 8, length: 17))

        XCTAssertEqual(test, reference)
    }

//    func testRange() {
//        let str = "Hello World!!!"
//
//        let test = "Hello World!!!".style(range: str.startIndex..<str.index(str.startIndex, offsetBy: 5), style: Style("b").font(.boldSystemFont(ofSize: 45))).attributedString
//
//        let reference = NSMutableAttributedString(string: "Hello World!!!")
//        reference.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 45)], range: NSMakeRange(0, 5))
//
//        XCTAssertEqual(test, reference)
//    }

    func testEmojis() {
        let testHTML = "Hello <b>W🌎rld</b>!!!"

        let test = self.parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Hello W🌎rld!!!")
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 0, length: 6))
        reference.addAttributes(self.defaultBoldStyle, range: NSRange(location: 6, length: 6))
        reference.addAttributes(self.defaultStyle, range: NSRange(location: 12, length: 3))

        XCTAssertEqual(test,reference)
    }

    func testImages() {
        XCTFail("Implement")
    }

//    func testTransformers() {
//
//        let transformers: [TagTransformer] = [
//            TagTransformer.brTransformer,
//            TagTransformer(tagName: "li", tagType: .start, replaceValue: "- "),
//            TagTransformer(tagName: "li", tagType: .end, replaceValue: "\n")
//        ]
//
//        let li = Style("li").font(.systemFont(ofSize: 12))
//
//        let test = "TODO:<br><li>veni</li><li>vidi</li><li>vici</li>"
//            .style(tags: li, transformers: transformers)
//            .attributedString
//
//        let reference = NSMutableAttributedString(string: "TODO:\n- veni\n- vidi\n- vici\n")
//        reference.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)], range: NSMakeRange(6, 6))
//        reference.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)], range: NSMakeRange(13, 6))
//        reference.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)], range: NSMakeRange(20, 6))
//
//        XCTAssertEqual(test,reference)
//    }

/*
    func testOL() {
        var counter = 0
        let transformers: [TagTransformer] = [
            TagTransformer.brTransformer,
            TagTransformer(tagName: "ol", tagType: .start) { _ in
                counter = 0
                return ""
            },
            TagTransformer(tagName: "li", tagType: .start) { _ in
                counter += 1
                return "\(counter). "
            },
            TagTransformer(tagName: "li", tagType: .end) { _ in
                return "\n"
            }
        ]

        let test = "<div><ol type=\"\"><li>Coffee</li><li>Tea</li><li>Milk</li></ol><ol type=\"\"><li>Coffee</li><li>Tea</li><li>Milk</li></ol></div>".style(tags: [], transformers: transformers).string
        let reference = "1. Coffee\n2. Tea\n3. Milk\n1. Coffee\n2. Tea\n3. Milk\n"

        XCTAssertEqual(test,reference)
    }

    func testStyleBuilder() {

        let s = Style
            .font(.boldSystemFont(ofSize: 12), .normal)
            .font(.systemFont(ofSize: 12), .highlighted)
            .font(.boldSystemFont(ofSize: 13), .normal)
            .foregroundColor(.red, .normal)
            .foregroundColor(.green, .highlighted)

        let ref = Style("", [.normal: [.font: UIFont.boldSystemFont(ofSize: 13) as Any, .foregroundColor: UIColor.red as Any],
                             .highlighted: [.font: UIFont.systemFont(ofSize: 12) as Any,  .foregroundColor: UIColor.green as Any]])


        XCTAssertEqual("test".styleAll(s).attributedString,"test".styleAll(ref).attributedString)
    }

    func testStyleBuilder2() {

        let s = Style
            .foregroundColor(.red, .normal)
            .font(.boldSystemFont(ofSize: 12), .normal)
            .font(.boldSystemFont(ofSize: 13), .normal)
            .foregroundColor(.green, .highlighted)
            .font(.systemFont(ofSize: 12), .highlighted)

        let ref = Style("", [.normal: [.font: UIFont.boldSystemFont(ofSize: 13) as Any, .foregroundColor: UIColor.red as Any],
                             .highlighted: [.font: UIFont.systemFont(ofSize: 12) as Any,  .foregroundColor: UIColor.green as Any]])

        XCTAssertEqual("test".styleAll(s).attributedString,"test".styleAll(ref).attributedString)
    }

    func testHelloWithRHTMLTag() {
        let test = "\r\n<a style=\"text-decoration:none\" href=\"http://www.google.com\">Hello World</a>".style(tags:
            Style("a").font(.boldSystemFont(ofSize: 45))
            ).attributedString

        let reference1 = NSMutableAttributedString.init(string: "Hello World")

        XCTAssertEqual(reference1.length, 11)
        XCTAssertEqual(reference1.string.count, 11)

        let reference2 = NSMutableAttributedString.init(string: "\rHello World")

        XCTAssertEqual(reference2.length, 12)
        XCTAssertEqual(reference2.string.count, 12)

        let reference3 = NSMutableAttributedString.init(string: "\r\nHello World")

        XCTAssertEqual(reference3.length, 13)
        XCTAssertEqual(reference3.string.count, 12)

        reference3.addAttributes([NSAttributedStringKey.font: Font.boldSystemFont(ofSize: 45)], range: NSRange(reference3.string.range(of: "Hello World")!, in: reference3.string) )

        XCTAssertEqual(test, reference3)
    }

    func testTagAttributes() {
        let test = "Hello <a class=\"big\" target=\"\" href=\"http://foo.com\">world</a>!"

        let (string, tags) = test.detectTags()


        XCTAssertEqual(string, "Hello world!")
        XCTAssertEqual(tags[0].tag.attributes["class"], "big")
        XCTAssertEqual(tags[0].tag.attributes["target"], "")
        XCTAssertEqual(tags[0].tag.attributes["href"], "http://foo.com")
    }
  */

}
