//
//  VideoQualityViewController
//  xikolo-ios
//
//  Created by Max Bothe on 18.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import UIKit

class VideoQualityViewController: UITableViewController {

    private static let downloadQualitySection = 0

    // data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VideoPersistenceQuality.orderedValues.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("settings.video-persistence-quality.section-header.download quality",
                                 comment: "section title for download quality")
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPersistenceQualityCell", for: indexPath)
        let videoQuality = VideoPersistenceQuality.orderedValues[indexPath.row]
        cell.textLabel?.text = videoQuality.description
        cell.accessoryType = videoQuality == UserDefaults.standard.videoPersistenceQuality ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldVideoQuality = UserDefaults.standard.videoPersistenceQuality
        let newVideoQuality = VideoPersistenceQuality.orderedValues[indexPath.row]

        if oldVideoQuality != newVideoQuality {
            // update preferred video download quality
            UserDefaults.standard.videoPersistenceQuality = newVideoQuality
            UserDefaults.standard.synchronize()
            if let oldVideoQualityRow = VideoPersistenceQuality.orderedValues.index(of: oldVideoQuality) {
                let oldVideoQualityIndexPath = IndexPath(row: oldVideoQualityRow, section: VideoQualityViewController.downloadQualitySection)
                tableView.reloadRows(at: [oldVideoQualityIndexPath, indexPath], with: .none)
            } else {
                let indexSet = IndexSet(integer: VideoQualityViewController.downloadQualitySection)
                tableView.reloadSections(indexSet, with: .none)
            }
        }
    }
}
