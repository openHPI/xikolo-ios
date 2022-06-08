//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class HeaderTableViewDiffableDataSource: UITableViewDiffableDataSource<String, NSObject> {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.snapshot().sectionIdentifiers[section]
    }

}
