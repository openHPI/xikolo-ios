//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

class AppearanceSettingsViewController: UITableViewController {

    // data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsOptionBasicCell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("appearance.settings-device", comment: "Title for selecting device apperance option")
        case 1:
            cell.textLabel?.text = NSLocalizedString("appearance.settings-light", comment: "Title for selecting light apperance option")
        case 2:
            cell.textLabel?.text = NSLocalizedString("appearance.settings-dark", comment: "Title for selecting dark apperance option")
        default:
            cell.textLabel?.text = nil
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("settings.cell-title.appearance-settings", comment: "cell title for appearance settings")
        default:
            return nil
        }

    }
}
