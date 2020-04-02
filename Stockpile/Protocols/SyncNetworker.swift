//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

public protocol SyncNetworker {

    func perform(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)

}
