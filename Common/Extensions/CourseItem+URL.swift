//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

extension CourseItem {

    public var url: URL? {
        guard let courseSlug = self.section?.course?.slug else { return nil }
        guard let courseItemId = self.base62id else { return nil }
        return Routes.courses.appendingPathComponents([courseSlug, "items", courseItemId])
    }

}
