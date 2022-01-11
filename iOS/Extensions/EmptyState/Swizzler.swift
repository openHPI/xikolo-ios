//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

enum Swizzler {

    static func swizzleMethods(for sourceClass: AnyClass?, originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(sourceClass, originalSelector),
            let swizzledMethod = class_getInstanceMethod(sourceClass, swizzledSelector) else {
                return
        }

        let didAddMethod = class_addMethod(sourceClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

        if didAddMethod {
            class_replaceMethod(sourceClass.self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

}
