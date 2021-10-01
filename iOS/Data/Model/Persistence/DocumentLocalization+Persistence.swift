//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension DocumentLocalization: Persistable {

    static let identifierKeyPath: WritableKeyPath<DocumentLocalization, String> = \DocumentLocalization.id

    override public func prepareForDeletion() { // swiftlint:disable:this override_in_extension
        super.prepareForDeletion()
        DocumentsPersistenceManager.shared.prepareForDeletion(of: self)
    }

}
