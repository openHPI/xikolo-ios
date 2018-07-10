//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension UserHelper {

    public struct FetchRequest {

        public static func user(withId userId: String) -> NSFetchRequest<User> {
            let request: NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", userId)
            request.fetchLimit = 1
            return request
        }

    }

}
