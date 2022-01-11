//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension UserHelper {

    public enum FetchRequest {

        public static func user(withId userId: String) -> NSFetchRequest<User> {
            let request: NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", userId)
            request.fetchLimit = 1
            return request
        }

    }

}
