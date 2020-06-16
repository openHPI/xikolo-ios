//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import MobileCoreServices

extension CourseItem: NSItemProviderWriting {

    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [
            kUTTypeURL as String,
            kUTTypeUTF8PlainText as String,
        ]
    }

    public func loadData(withTypeIdentifier typeIdentifier: String,
                         forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        if typeIdentifier == kUTTypeUTF8PlainText as String {
            let titleUrl = [self.title, self.url?.absoluteString].compactMap { $0 }.joined(separator: "\n")
            completionHandler(titleUrl.data(using: .utf8), nil)
        } else if typeIdentifier == kUTTypeURL as String {
            let dropRepresentation = self.url.flatMap { URLDropRepresentation(url: $0, title: self.title) }
            let data = try? dropRepresentation.map(PropertyListEncoder().encode)
            completionHandler(data, nil)
        }

        return nil
    }

}
