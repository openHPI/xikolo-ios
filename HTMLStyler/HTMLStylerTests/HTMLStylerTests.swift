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

    private struct ListStyleCollection: StyleCollection {
        func style(for tag: Tag, isLastSibling: Bool) -> Style? {
            guard case .listItem(style: _, depth: _) = tag else { return nil }
            let color: UIColor = isLastSibling ? .red : .blue
            return [.foregroundColor: color]
        }
    }

    private struct ImageStyleCollection: StyleCollection {

        let image: UIImage

        init(image: UIImage) {
            self.image = image
        }

        public func replacement(for tag: Tag) -> NSAttributedString? {
            switch tag {
            case .image(_):
                let attachment = ImageTextAttachment()
                attachment.image = self.image

                let attachmentString = NSAttributedString(attachment: attachment)
                let attributedString = NSMutableAttributedString(attributedString: attachmentString)
                attributedString.append(NSAttributedString(string: "\n"))
                return attributedString
            default:
                return nil
            }
        }
    }

    func testEmpty() {
        let parser = Parser()

        let testHTML = "Fizz Buzz!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz Buzz!!!")

        XCTAssertEqual(test, reference)
    }

    func testBase() {
        var parser = Parser()
        parser.styleCollection = BaseStyleCollection()

        let testHTML = "Fizz Buzz!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz Buzz!!!")
        reference.addAttributes(parser.styleCollection!.baseStyle, range: NSRange(location: 0, length: 12))

        XCTAssertEqual(test, reference)
    }

    func testManyTags() {
        var parser = Parser()
        parser.styleCollection = BoldAndItalicStyleCollection()

        let testHTML = "Fi<i>zz</i> <b>Buzz</b>!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz Buzz!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .italic, isLastSibling: true)!, range: NSRange(location: 2, length: 2))
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 5, length: 4))

        XCTAssertEqual(test, reference)
    }

    func testManySameTags() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Fi<b>zz</b> <b>Buzz</b>!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz Buzz!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 2, length: 2))
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 5, length: 4))

        XCTAssertEqual(test, reference)
    }

    func testTagsNested() {
        var parser = Parser()
        parser.styleCollection = BoldAndItalicStyleCollection()

        let testHTML = "Fizz <b>B<i>uzz</i>!!!</b>"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz Buzz!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 5, length: 1))
        reference.addAttributes(parser.styleCollection!.style(for: .italic, isLastSibling: true)!, range: NSRange(location: 6, length: 3))
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 9, length: 3))

        XCTAssertEqual(test, reference)
    }

    func testNotClosedTag() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Fizz <b>Buzz!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz Buzz!!!")

        XCTAssertEqual(test, reference)
    }

    func testNotOpenedTag() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Fizz </b>Buzz!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz Buzz!!!")

        XCTAssertEqual(test, reference)
    }

    func testBold() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Fizz <b>Buzz</b>!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz Buzz!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 5, length: 4))

        XCTAssertEqual(test, reference)
    }

    func testParagraph() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "<p>Fizz</p>Buzz!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz\nBuzz!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 0, length: 5))

        XCTAssertEqual(test, reference)
    }

    func testNewLine() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Fizz<br>Buzz!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSAttributedString(string: "Fizz\nBuzz!!!")

        XCTAssertEqual(test, reference)
    }

    func testNewLine2() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Fizz<br />Buzz!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSAttributedString(string: "Fizz\nBuzz!!!")

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

    func testList() {
        var parser = Parser()
        parser.styleCollection = ListStyleCollection()

        let testHTML = """
        <ul>
        <li>Item 1</li>
        <li>Item 2</li>
        </ul>
        """
        let test = parser.attributedString(for: testHTML)

        let referenceText = """
        •\tItem 1
        •\tItem 2
        """
        let reference = NSMutableAttributedString(string: referenceText)

        let normalItemStyle = parser.styleCollection!.style(for: .listItem(style: .unordered, depth: 0), isLastSibling: false)!
        let lastItemStyle = parser.styleCollection!.style(for: .listItem(style: .unordered, depth: 0), isLastSibling: true)!
        reference.addAttributes(normalItemStyle, range: NSRange(location: 0, length: 9))
        reference.addAttributes(lastItemStyle, range: NSRange(location: 9, length: 8))

        XCTAssertEqual(test, reference)
    }

    func testListWithTags() {
        var parser = Parser()
        parser.styleCollection = ListStyleCollection()

        let testHTML = """
        <ul>
        <li>Item <b>1</b></li>
        <li>Item <b>2</b></li>
        </ul>
        """
        let test = parser.attributedString(for: testHTML)

        let referenceText = """
        •\tItem 1
        •\tItem 2
        """
        let reference = NSMutableAttributedString(string: referenceText)

        let normalItemStyle = parser.styleCollection!.style(for: .listItem(style: .unordered, depth: 0), isLastSibling: false)!
        let lastItemStyle = parser.styleCollection!.style(for: .listItem(style: .unordered, depth: 0), isLastSibling: true)!
        reference.addAttributes(normalItemStyle, range: NSRange(location: 0, length: 9))
        reference.addAttributes(lastItemStyle, range: NSRange(location: 9, length: 8))

        XCTAssertEqual(test, reference)
    }

    func testMultipleLists() {
        var parser = Parser()
        parser.styleCollection = ListStyleCollection()

        let testHTML = """
        <ul>
        <li>Item 1</li>
        <li>Item 2</li>
        </ul>
        <ul>
        <li>Item 1</li>
        <li>Item 2</li>
        </ul>
        """

        let test = parser.attributedString(for: testHTML)

        let referenceText = """
        •\tItem 1
        •\tItem 2
        •\tItem 1
        •\tItem 2
        """
        let reference = NSMutableAttributedString(string: referenceText)

        let normalItemStyle = parser.styleCollection!.style(for: .listItem(style: .unordered, depth: 0), isLastSibling: false)!
        let lastItemStyle = parser.styleCollection!.style(for: .listItem(style: .unordered, depth: 0), isLastSibling: true)!
        reference.addAttributes(normalItemStyle, range: NSRange(location: 0, length: 9))
        reference.addAttributes(lastItemStyle, range: NSRange(location: 9, length: 9))
        reference.addAttributes(normalItemStyle, range: NSRange(location: 18, length: 9))
        reference.addAttributes(lastItemStyle, range: NSRange(location: 27, length: 8))

        XCTAssertEqual(test, reference)
    }

    func testUnorderedList() {
        let parser = Parser()

        let testHTML = """
        <ul>
        <li>Item 1</li>
        <li>Item 2</li>
        </ul>
        """
        let test = parser.attributedString(for: testHTML)

        let referenceText = """
        •\tItem 1
        •\tItem 2
        """
        let reference = NSMutableAttributedString(string: referenceText)

        XCTAssertEqual(test, reference)
    }

    func testNestedUnorderedLists() {
        let parser = Parser()

        let testHTML = """
        <ul>
        <li>Item 1</li>
        <ul>
        <li>Item 2</li>
        <ul>
        <li>Item 3</li>
        <ul>
        <li>Item 4</li>
        <li>Item 5</li>
        </ul>
        <li>Item 6</li>
        </ul>
        <li>Item 7</li>
        </ul>
        <li>Item 8</li>
        </ul>
        """
        let test = parser.attributedString(for: testHTML)

        let referenceText = """
        •\tItem 1
        \t◦\tItem 2
        \t\t■\tItem 3
        \t\t\t■\tItem 4
        \t\t\t■\tItem 5
        \t\t■\tItem 6
        \t◦\tItem 7
        •\tItem 8
        """
        let reference = NSMutableAttributedString(string: referenceText)

        XCTAssertEqual(test, reference)
    }

    func testOrderedLists() {
        let parser = Parser()

        let testHTML = """
        <ol>
        <li>Item 1</li>
        <li>Item 2</li>
        </ol>
        """
        let test = parser.attributedString(for: testHTML)

        let referenceText = """
        1.\tItem 1
        2.\tItem 2
        """
        let reference = NSMutableAttributedString(string: referenceText)

        XCTAssertEqual(test, reference)
    }

    func testNestedOrderedLists() {
        let parser = Parser()

        let testHTML = """
        <ol>
        <li>Item 1</li>
        <ol>
        <li>Item 2</li>
        <ol>
        <li>Item 3</li>
        <ol>
        <li>Item 4</li>
        <li>Item 5</li>
        </ol>
        <li>Item 6</li>
        </ol>
        <li>Item 7</li>
        </ol>
        <li>Item 8</li>
        </ol>
        """
        let test = parser.attributedString(for: testHTML)

        let referenceText = """
        1.\tItem 1
        \t1.\tItem 2
        \t\t1.\tItem 3
        \t\t\t1.\tItem 4
        \t\t\t2.\tItem 5
        \t\t2.\tItem 6
        \t2.\tItem 7
        2.\tItem 8
        """
        let reference = NSMutableAttributedString(string: referenceText)

        XCTAssertEqual(test, reference)
    }

    func testNestedMixedLists() {
        let parser = Parser()

        let testHTML = """
        <ol>
        <li>Item 1</li>
        <ul>
        <li>Item 2</li>
        <ol>
        <li>Item 3</li>
        <ul>
        <li>Item 4</li>
        <li>Item 5</li>
        </ul>
        <li>Item 6</li>
        </ol>
        <li>Item 7</li>
        </ul>
        <li>Item 8</li>
        </ol>
        """
        let test = parser.attributedString(for: testHTML)

        let referenceText = """
        1.\tItem 1
        \t◦\tItem 2
        \t\t1.\tItem 3
        \t\t\t■\tItem 4
        \t\t\t■\tItem 5
        \t\t2.\tItem 6
        \t◦\tItem 7
        2.\tItem 8
        """
        let reference = NSMutableAttributedString(string: referenceText)

        XCTAssertEqual(test, reference)
    }

    func testEmojis() {
        var parser = Parser()
        parser.styleCollection = BoldStyleCollection()

        let testHTML = "Fizz <b>B🤘zz</b>!!!"
        let test = parser.attributedString(for: testHTML)

        let reference = NSMutableAttributedString(string: "Fizz B🤘zz!!!")
        reference.addAttributes(parser.styleCollection!.style(for: .bold, isLastSibling: true)!, range: NSRange(location: 5, length: 5))

        XCTAssertEqual(test,reference)
    }

    func testImage() {
        let rect = CGRect(origin: .zero, size: CGSize(width: 200, height: 75))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        UIColor.red.setFill()
        UIRectFill(rect)
        let rawImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = rawImage?.cgImage else {
            XCTFail("Unable to create test image")
            return
        }

        let image = UIImage(cgImage: cgImage)

        var parser = Parser()
        parser.styleCollection = ImageStyleCollection(image: image)

        let testHTML = "<img src=\"path/to/test-image.png\" />!!!"
        let test = parser.attributedString(for: testHTML)

        let attachment = ImageTextAttachment()
        attachment.image = image
        let attachmentString = NSAttributedString(attachment: attachment)
        let reference = NSMutableAttributedString(attributedString: attachmentString)
        reference.append(NSAttributedString(string: "\n!!!"))

        XCTAssertEqual(test.string, reference.string)

        let testAttachment = test.attribute(.attachment, at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: 0)) as? ImageTextAttachment
        XCTAssertNotNil(testAttachment)

        let referenceAttachment = reference.attribute(.attachment, at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: 0)) as? ImageTextAttachment
        XCTAssertNotNil(referenceAttachment)

        XCTAssertEqual(testAttachment?.image, referenceAttachment?.image)
    }

}
