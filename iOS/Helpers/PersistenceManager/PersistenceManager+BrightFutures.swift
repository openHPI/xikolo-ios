//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common

extension PersistenceManager {

    @discardableResult
    func startDownload(with url: URL, for resource: Resource, options: [PersistenceManager.Option] = []) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        self.startDownload(with: url, for: resource, options: options) { result in
            promise.complete(result)
        }

        return promise.future
    }

    @discardableResult
    func deleteDownload(for resource: Resource) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        self.deleteDownload(for: resource) { result in
            promise.complete(result)
        }

        return promise.future
    }

}
