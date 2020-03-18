//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public typealias Style = [NSAttributedString.Key: Any]

public protocol StyleCollection {

    var baseStyle: Style { get }

    func style(for tag: Tag, isLastSibling: Bool) -> Style?

    func replacement(for tag: Tag, with layoutChangeHandler: (() -> Void)?) -> NSAttributedString?

}

public extension StyleCollection {

    var baseStyle: Style {
        return [:]
    }

    func style(for tag: Tag, isLastSibling: Bool) -> Style? {
        return nil
    }

    func replacement(for tag: Tag, with layoutChangeHandler: (() -> Void)?) -> NSAttributedString? {
        return nil
    }

}
