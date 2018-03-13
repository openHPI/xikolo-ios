//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

class DownloadSettingsViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.presentingViewController?.traitCollection.horizontalSizeClass != .regular {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return VideoQuality.orderedValues.count
        case 1:
            return CourseItemContentPreloadSetting.orderedValues.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("settings.video-quality.section-header.download quality",
                                     comment: "section title for download quality")
        case 1:
            return NSLocalizedString("settings.course-item-content-preload.section-header.course content",
                                     comment: "section header for preload setting for course content")
        default:
            return nil
        }

    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            return NSLocalizedString("settings.course-item-content-preload.section-footer",
                                     comment: "section footer for preload setting for course content")
        default:
            return nil
        }
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsOptionBasicCell", for: indexPath)

        switch indexPath.section {
        case 0:
            let videoQuality = VideoQuality.orderedValues[indexPath.row]
            cell.textLabel?.text = videoQuality.description
            cell.accessoryType = videoQuality == UserDefaults.standard.videoQualityForDownload ? .checkmark : .none
        case 1:
            let preloadOption = CourseItemContentPreloadSetting.orderedValues[indexPath.row]
            cell.textLabel?.text = preloadOption.description
            cell.accessoryType = preloadOption == UserDefaults.standard.contentPreloadSetting ? .checkmark : .none
        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var newRow: Int?

        switch indexPath.section {
        case 0:
            let oldVideoQuality = UserDefaults.standard.videoQualityForDownload
            let newVideoQuality = VideoQuality.orderedValues[indexPath.row]
            if oldVideoQuality != newVideoQuality {
                UserDefaults.standard.videoQualityForDownload = newVideoQuality
                newRow = VideoQuality.orderedValues.index(of: oldVideoQuality)
            }
        case 1:
            let oldPreloadOption = UserDefaults.standard.contentPreloadSetting
            let newPreloadOption = CourseItemContentPreloadSetting.orderedValues[indexPath.row]
            if oldPreloadOption != newPreloadOption {
                UserDefaults.standard.contentPreloadSetting = newPreloadOption
                newRow = CourseItemContentPreloadSetting.orderedValues.index(of: oldPreloadOption)
            }
        default:
            break
        }

        self.switchSelectedSettingsCell(at: indexPath, to: newRow)
    }

    private func switchSelectedSettingsCell(at indexPath: IndexPath, to row: Int?) {
        if let row = row {
            let oldRow = IndexPath(row: row, section: indexPath.section)
            tableView.reloadRows(at: [oldRow, indexPath], with: .none)
        } else {
            let indexSet = IndexSet(integer: indexPath.section)
            tableView.reloadSections(indexSet, with: .none)
        }
    }
}

