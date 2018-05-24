//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Down
import HTMLStyler

struct MarkdownHelper {

    static let parser: Parser = {
        var parser = Parser()
        parser.styleCollection = DefaultStyleCollection(tintColor: Brand.Color.primary)
        return parser
    }()

    static func parse(_ string: String) throws -> NSMutableAttributedString {
        let string2 = """
        <h1 align="center">
        xikolo-ios
        </h1>

        <img align="center" src="assets/banner.png?raw=true" alt="xikolo-ios banner" width="933" />

        <p align="center">
        iOS application for openHPI, openSAP, mooc.house and OpenWHO
        </p>

        <p align="center">
        <img src="https://travis-ci.org/openHPI/xikolo-ios.svg?branch=dev" />
        <img src="https://img.shields.io/badge/License-MIT-yellow.svg" />
        </p>

        ### Development toolchain
        - Xcode 9.3
        - bundler: `gem install bundler`

        The following tools will be installed via bundler:
        - [CocoaPods](https://cocoapods.org/)
        - [fastlane](https://fastlane.tools/)

        The following tools will be installed via CocoaPods:
        - [SwiftLint](https://github.com/realm/SwiftLint)
        - [BartyCrouch](https://github.com/Flinesoft/BartyCrouch)

        ## How to get started
        - clone this repository
        - run `bundle install`
        - run `bundle exec pod repo update` and `bundle exec pod install`
        - open xikolo-ios.xcworkspace in Xcode
        - start one of the defined targets

        ### Setup testing
        - copy the credentials plist dummy file `cp UI\\ Tests/Credentials.plist.dummy UI\\ Tests/Credentials.plist`
        - enter your login credentials for testing

        ## Contribute to _xikolo-ios_
        Check out [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

        ## Code of Conduct
        Help us keep this project open and inclusive. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

        ## License
        This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.

        https://google.com
        """

        let html = try? Down(markdownString: string2).toHTML()
//        return NSMutableAttributedString(string: html ?? "")
        return self.parser.attributedString(for: html ?? "")

//        let parser = Down(markdownString: string)
//
//        #if os(tvOS)
//            let color = "white"
//        #else
//            let color = "black"
//        #endif
//
//        if let attributedString = try? parser.toAttributedStringWithFont(font: "-apple-system-body", color: color) {
//            let mutableString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
//            return mutableString
//        } else {
//            throw XikoloError.markdownError
//        }
    }

    static func trueScheme(for url: URL) -> URL? {
        var url = url
        if url.scheme == "applewebdata" { // replace applewebdata with baseURL for relative urls in markdown
            var absoluteString = url.absoluteString
            let trimmedUrlString = absoluteString.stringByRemovingRegexMatches(pattern: "^(?:applewebdata://[0-9A-Z-]*/?)",
                                                                               replaceWith: Routes.base.absoluteString + "/")
            guard let trimmedString = trimmedUrlString else { return nil }
            guard let trimmedURL = URL(string: trimmedString) else { return nil }
            url = trimmedURL
        }

        guard url.scheme?.hasPrefix("http") ?? false else { return nil }

        return url
    }

}

extension DownAttributedStringRenderable {

    func toAttributedStringWithFont(_ options: DownOptions = .default, font: String, color: String) throws -> NSAttributedString {
        let htmlResponse = try self.toHTML(options)
        let html = "<span style=\"font: \(font); color: \(color);\">\(htmlResponse)</span>"
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]
        let mutableString = try NSMutableAttributedString(data: Data(html.utf8), options: options, documentAttributes: nil)
        return mutableString //.trimmedAttributedString(set: .whitespacesAndNewlines)
    }

}
