//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures

extension AsyncType where Value: ResultProtocol {

    func inject(_ context: @escaping ExecutionContext = DefaultThreadingModel(),
                callback: @escaping () -> Result<Void, Self.Value.Error>) -> Future<Self.Value.Value, Self.Value.Error> {
        return self.flatMap(context) { value in
            return callback().map { value }
        }
    }

}
