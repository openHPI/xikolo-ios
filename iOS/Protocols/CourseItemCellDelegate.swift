//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

protocol CourseItemCellDelegate {

    var inOfflineMode: Bool { get }
    func isPreloading(for contentType: String?) -> Bool

}
