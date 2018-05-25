//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class AbstractItemRichtextViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel! // swiftlint:disable:this private_outlet
    @IBOutlet weak var textView: UITextView! // swiftlint:disable:this private_outlet

    var courseItem: CourseItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateView(for: self.courseItem)
        CourseItemHelper.syncCourseItemWithContent(self.courseItem).onSuccess { syncResult in
            CoreDataHelper.viewContext.perform {
                guard let courseItem = CoreDataHelper.viewContext.existingTypedObject(with: syncResult.objectId) as? CourseItem else {
                    log.warning("Failed to retrieve course item to display")
                    return
                }

                self.courseItem = courseItem
                DispatchQueue.main.async {
                    self.updateView(for: self.courseItem)
                }
            }
        }
    }

    private func updateView(for courseItem: CourseItem) {
        self.titleView.text = self.courseItem.title

        guard let richText = courseItem.content as? RichText, let markdown = richText.text else {
            self.textView.isHidden = true
            return
        }

        self.display(markdown: markdown)
    }

    func display(markdown: String) {
        let markdown2 = """
        <h1 align="center">
        xikolo-ios
        </h1>

        <img align="center" src="https://rawgit.com/openHPI/xikolo-ios/dev/assets/banner.png" alt="xikolo-ios banner" width="933" />

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


        let markDown = MarkdownHelper.attributedString(for: markdown2)
        self.textView.attributedText = markDown
        self.textView.isHidden = false
        self.richTextLoaded()
    }

    func richTextLoaded() {
        // Do nothing. Subclasses can customize this method.
    }

}
