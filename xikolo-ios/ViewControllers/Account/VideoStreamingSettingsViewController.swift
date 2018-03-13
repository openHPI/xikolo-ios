//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

class VideoStreamingSettingsViewController: UITableViewController {

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
        // yes, each section has the same options for video quality
        return VideoQuality.orderedValues.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("settings.video-quality.section-header.on cellular",
                                     comment: "section title for video quality on cellular connection")
        case 1:
            return NSLocalizedString("settings.video-quality.section-header.on wifi",
                                     comment: "section title for video quality on wifi connection")
        default:
            return nil
        }
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsOptionBasicCell", for: indexPath)
        let videoQuality = VideoQuality.orderedValues[indexPath.row]
        cell.textLabel?.text = videoQuality.description

        if let videoQualityKeyPath = self.videoQualityKeyPath(for: indexPath.section) {
            let currentVideoQuality = UserDefaults.standard[keyPath: videoQualityKeyPath]
            cell.accessoryType = videoQuality == currentVideoQuality ? .checkmark : .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let videoQualityKeyPath = self.videoQualityKeyPath(for: indexPath.section) else { return }

        let oldVideoQuality = UserDefaults.standard[keyPath: videoQualityKeyPath]
        let newVideoQuality = VideoQuality.orderedValues[indexPath.row]

        if oldVideoQuality != newVideoQuality {
            // update preferred video quality
            UserDefaults.standard[keyPath: videoQualityKeyPath] = newVideoQuality

            if let oldVideoQualityRow = VideoQuality.orderedValues.index(of: oldVideoQuality) {
                let oldVideoQualityIndexPath = IndexPath(row: oldVideoQualityRow, section: indexPath.section)
                tableView.reloadRows(at: [oldVideoQualityIndexPath, indexPath], with: .none)
            } else {
                let indexSet = IndexSet(integer: indexPath.section)
                tableView.reloadSections(indexSet, with: .none)
            }
        }
    }

    private func videoQualityKeyPath(for section: Int) -> ReferenceWritableKeyPath<UserDefaults, VideoQuality>? {
        switch section {
        case 0:
            return \UserDefaults.videoQualityOnCellular
        case 1:
            return \UserDefaults.videoQualityOnWifi
        default:
            return nil
        }
    }
}
