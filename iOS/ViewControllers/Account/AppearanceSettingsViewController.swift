//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

class AppearanceSettingsViewController: UITableViewController {

    @available(iOS 13.0, *)
    private var theme: Theme {
        get {
            return UserDefaults.standard.theme
        }
        set {
            UserDefaults.standard.theme = newValue
            self.configureStyle(for: newValue)
        }
    }

    @available(iOS 13.0, *)
    private func configureStyle(for theme: Theme) {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = theme.userInterfaceStyle
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsOptionBasicCell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("settings.appearance.device", comment: "Title for selecting device apperance option")
        case 1:
            cell.textLabel?.text = NSLocalizedString("settings.appearance.light", comment: "Title for selecting light apperance option")
        case 2:
            cell.textLabel?.text = NSLocalizedString("settings.appearance.dark", comment: "Title for selecting dark apperance option")
        default:
            cell.textLabel?.text = nil
        }

        if #available(iOS 13.0, *) {
            cell.accessoryType = indexPath.row == self.theme.rawValue ? .checkmark : .none
//            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if #available(iOS 13.0, *) {
            if indexPath.row != self.theme.rawValue {
                let oldAppearanceSettingIndexPath = IndexPath(row: self.theme.rawValue, section: indexPath.section)
                self.theme = Theme(rawValue: indexPath.row) ?? .device
                tableView.reloadRows(at: [oldAppearanceSettingIndexPath, indexPath], with: .none)
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("settings.cell-title.appearance", comment: "cell title for appearance settings")
        default:
            return nil
        }
    }
}
