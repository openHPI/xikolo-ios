//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

// Eventually these have to be moved to real feature flippers fetched from the server
public struct BrandFeatures: Decodable {

    public let enableChannels: Bool
    public let enableDocuments: Bool
    public let enableCollabSpace: Bool
    public let showCourseTeachers: Bool

}
