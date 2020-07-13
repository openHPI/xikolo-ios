//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

class AppearanceSettingsViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if #available(iOS 13.0, *) {
            return Theme.allCases.count
        } else {
            return 0
        }
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsOptionBasicCell", for: indexPath)

        if #available(iOS 13.0, *) {
            cell.textLabel?.text = Theme.allCases[indexPath.row].title
            cell.accessoryType = indexPath.row == UserDefaults.standard.theme.rawValue ? .checkmark : .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if #available(iOS 13.0, *) {
            if indexPath.row != UserDefaults.standard.theme.rawValue {
                let oldAppearanceSettingIndexPath = IndexPath(row: UserDefaults.standard.theme.rawValue, section: indexPath.section)
                UserDefaults.standard.theme = Theme(rawValue: indexPath.row) ?? .device
                tableView.reloadRows(at: [oldAppearanceSettingIndexPath, indexPath], with: .none)
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("settings.cell-title.appearance", comment: "cell title for appearance settings")
    }
}
