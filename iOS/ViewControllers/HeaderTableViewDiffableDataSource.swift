//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class HeaderTableViewDiffableDataSource: UITableViewDiffableDataSource<String, NSObject> {

    override func tableView(_ tableView: UITableView,  titleForHeaderInSection section: Int) -> String? {
        return self.snapshot().sectionIdentifiers[section]
    }

}
