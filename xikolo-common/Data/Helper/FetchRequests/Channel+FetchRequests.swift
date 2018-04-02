//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension ChannelHelper {

    struct FetchRequest {

        static var allChannels: NSFetchRequest<Channel> {
            let request: NSFetchRequest<Channel> = Channel.fetchRequest()
            let positionSort = NSSortDescriptor(key: "position", ascending: true)
            request.sortDescriptors = [positionSort]
            return request
        }

    }

}

