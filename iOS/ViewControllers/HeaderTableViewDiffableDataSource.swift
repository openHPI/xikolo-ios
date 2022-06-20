//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class StringSectionTableViewDiffableDataSource<ItemIdentifier>: UITableViewDiffableDataSource<String, ItemIdentifier> where ItemIdentifier: Hashable {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.snapshot().sectionIdentifiers[section]
    }

}
