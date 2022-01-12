//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation
import WebKit

class CourseItemWebViewController: WebViewController {

    var courseItem: CourseItem! {
        didSet {
            self.userScripts = [self.userScriptForCourseItemInset]
            self.url = self.courseItem.url
        }
    }

    var userScriptForCourseItemInset: WKUserScript {
        // swiftlint:disable closing_brace_whitespace
        let script = """
        const style = document.createElement('style');
        style.innerHTML = `
            @media (min-width: 576px) {
                #maincontent {
                    padding-left: 84px;
                    padding-right: 84px;
                }
            }
        `;
        document.head.appendChild(style);
        """
        // swiftlint:enable closing_brace_whitespace
        return WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

}

extension CourseItemWebViewController: CourseItemContentPresenter {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
