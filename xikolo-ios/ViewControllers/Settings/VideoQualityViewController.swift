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

    // data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // yes, each section has the same options for video quality
        return VideoQuality.orderedValues.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("settings.video-persistence-quality.section-header.download quality",
                                     comment: "section title for download quality")
        case 1:
            return "Cellular"
        case 2:
            return "Wifi"
        default:
            return nil
        }
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoQualityCell", for: indexPath)
        let videoQuality = VideoQuality.orderedValues[indexPath.row]
        cell.textLabel?.text = videoQuality.description

        var currentVideoQuality: VideoQuality?
        switch indexPath.section {
        case 0:
            currentVideoQuality = UserDefaults.standard.videoQualityForDownload
        case 1:
            currentVideoQuality = UserDefaults.standard.videoQualityOnCelluar
        case 2:
            currentVideoQuality = UserDefaults.standard.videoQualityOnWifi
        default:
            break
        }

        if let currentVideoQuality = currentVideoQuality {
            cell.accessoryType = videoQuality == currentVideoQuality ? .checkmark : .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newVideoQuality = VideoQuality.orderedValues[indexPath.row]
        var oldVideoQuality : VideoQuality?
        switch indexPath.section {
        case 0:
            oldVideoQuality = UserDefaults.standard.videoQualityForDownload
        case 1:
            oldVideoQuality = UserDefaults.standard.videoQualityOnCelluar
        case 2:
            oldVideoQuality = UserDefaults.standard.videoQualityOnWifi
        default:
            break
        }

        if oldVideoQuality != newVideoQuality {
            // update preferred video quality
            switch indexPath.section {
            case 0:
                UserDefaults.standard.videoQualityForDownload = newVideoQuality
            case 1:
                UserDefaults.standard.videoQualityOnCelluar = newVideoQuality
            case 2:
                UserDefaults.standard.videoQualityOnWifi = newVideoQuality
            default:
                break
            }

            if let oldVideoQuality = oldVideoQuality, let oldVideoQualityRow = VideoQuality.orderedValues.index(of: oldVideoQuality) {
                let oldVideoQualityIndexPath = IndexPath(row: oldVideoQualityRow, section: indexPath.section)
                tableView.reloadRows(at: [oldVideoQualityIndexPath, indexPath], with: .none)
            } else {
                let indexSet = IndexSet(integer: indexPath.section)
                tableView.reloadSections(indexSet, with: .none)
            }
        }
    }
}
