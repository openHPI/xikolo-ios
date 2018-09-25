//
//  Created for schulcloud-mobile-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Result

extension AsyncType where Value: ResultProtocol {

    func inject(_ context: @escaping ExecutionContext = DefaultThreadingModel(),
                callback: @escaping () -> Result<Void, Self.Value.Error>) -> Future<Self.Value.Value, Self.Value.Error> {
        return self.flatMap(context) { value in
            return callback().map { value }
        }
    }

}
