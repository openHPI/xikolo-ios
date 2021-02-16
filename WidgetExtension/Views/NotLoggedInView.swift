//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NotLoggedInView: View {

    var body: some View {
        VStack {
            Text("not-logged-in.headline")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            Text("not-logged-in.subline")
                .multilineTextAlignment(.center)
                .font(.system(.footnote))
                .foregroundColor(Color.secondary)
        }
        .padding()
    }

}

struct NotLoggedInView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NotLoggedInView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            NotLoggedInView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}
