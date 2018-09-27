//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Result

public enum ObjectState: Int16 {
    case unchanged = 0
    case new
    case modified
    case deleted
}

public protocol IncludedPushable {
    func resourceAttributes() -> [String: Any]
}

public protocol Pushable: ResourceTypeRepresentable, IncludedPushable, NSFetchRequestResult, Validatable {
    var objectStateValue: ObjectState.RawValue { get set }

    static func resourceData(attributes: [String: Any], relationships: [String: AnyObject]?) -> Result<Data, SyncError>

    func resourceRelationships() -> [String: AnyObject]?
    func markAsUnchanged()

    func resourceData() -> Result<Data, SyncError>
}

public extension Pushable {

    public var objectState: ObjectState {
        get {
            return ObjectState(rawValue: self.objectStateValue) ?? .unchanged
        }
        set {
            self.objectStateValue = newValue.rawValue
        }
    }

    func resourceRelationships() -> [String: AnyObject]? {
        return nil
    }

}
