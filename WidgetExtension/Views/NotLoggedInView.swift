//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NotLoggedInView: View {

    var body: some View {
        VStack {
            Text("Log into your account")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            Text("to the widget contentz")
                .multilineTextAlignment(.center)
                .font(.system(.footnote))
                .foregroundColor(Color.secondary)
        }
    }

}

struct NotLoggedInView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NotLoggedInView()
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            NotLoggedInView()
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}
