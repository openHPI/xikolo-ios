//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI

struct Backport<Content> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

extension Backport where Content: View {
    @ViewBuilder func widgetBackground<V: View>(@ViewBuilder backgroundView: () -> V = { Color(UIColor.systemBackground) }) -> some View {
        if #available(iOS 17, *) {
            content.containerBackground(for: .widget, content: backgroundView)
        } else {
            content
        }
    }

    @ViewBuilder func widgetPadding() -> some View {
        if #available(iOS 17, *) {
            content
        } else {
            content.padding()
        }
    }
}
