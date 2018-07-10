//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public protocol ImageLoader {
    static func load(for url: URL) -> UIImage?
}
