//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

public protocol SyncNetworker {

    func perform(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)

}
