//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension ChannelHelper {

    public enum FetchRequest {

       public static var orderedChannels: NSFetchRequest<Channel> {
            let request: NSFetchRequest<Channel> = Channel.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Channel.position, ascending: true)]
            return request
        }

        static func channel(withId channelId: String) -> NSFetchRequest<Channel> {
            let request: NSFetchRequest<Channel> = Channel.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", channelId)
            request.fetchLimit = 1
            return request
        }

    }

}
