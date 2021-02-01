//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SwiftUI

struct CourseView: View {

    var course: CourseViewModel

    let appIconWidth: Int = 20

    private var appBundle: Bundle {
        var bundle = Bundle.main

        if bundle.bundleURL.pathExtension == "appex" {
            // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
            let url = bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
            if let otherBundle = Bundle(url: url) {
                bundle = otherBundle
            }
        }

        return bundle
    }

    private var appIcon: UIImage? {
        guard let iconsDictionary = appBundle.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String] else {
            return nil
        }

        guard let iconName = iconFiles.first(where: { $0.hasSuffix("\(appIconWidth)x\(appIconWidth)") }) ?? iconFiles.last else {
            return nil
        }

        return UIImage(named: iconName, in: appBundle, with: nil)
    }

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .top) {
                Image(uiImage: course.image ?? UIImage())
                    .resizable()
                    .aspectRatio(1.6, contentMode: .fit)
                    .background(Color.blue)
                    .mask(
                        RoundedRectangle(cornerRadius: 6)
                    )
                    .shadow(color: Color.secondary.opacity(0.2), radius: 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                if let appIcon = appIcon {
                    Image(uiImage: appIcon)
                        .resizable()
                        .frame(width: CGFloat(appIconWidth), height: CGFloat(appIconWidth))
                        .background(Color.clear)
                        .mask(
                            RoundedRectangle(cornerRadius: 4)
                        )
                        .padding(4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }

            Text(course.title)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(Color.primary)

            if let itemTitle = course.itemTitle {
                Text(itemTitle)
                .font(.system(size: 12))
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
            }
        }
    }

}
