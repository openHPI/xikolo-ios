//
//  PreloadContentViewController.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.12.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import UIKit

class PreloadContentViewController: UITableViewController {

    private static let courseContentSection = 0

    // data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CourseItemContentPreloadSetting.orderedValues.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("settings.course-item-content-preload.section-header.course content",
                                 comment: "section header for preload setting for course content")
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("settings.course-item-content-preload.section-footer",
                                 comment: "section footer for preload setting for course content")
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseContentPreloadCell", for: indexPath)
        let preloadOption = CourseItemContentPreloadSetting.orderedValues[indexPath.row]
        cell.textLabel?.text = preloadOption.description
        cell.accessoryType = preloadOption == UserDefaults.standard.contentPreloadSetting ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldPreloadOption = UserDefaults.standard.contentPreloadSetting
        let newPreloadOption = CourseItemContentPreloadSetting.orderedValues[indexPath.row]

        if oldPreloadOption != newPreloadOption {
            // update preferred course content preload option
            UserDefaults.standard.contentPreloadSetting = newPreloadOption
            UserDefaults.standard.synchronize()
            if let oldPreloadOptionRow = CourseItemContentPreloadSetting.orderedValues.index(of: oldPreloadOption) {
                let oldPreloadOptionIndexPath = IndexPath(row: oldPreloadOptionRow, section: PreloadContentViewController.courseContentSection)
                tableView.reloadRows(at: [oldPreloadOptionIndexPath, indexPath], with: .none)
            } else {
                let indexSet = IndexSet(integer: PreloadContentViewController.courseContentSection)
                tableView.reloadSections(indexSet, with: .none)
            }
        }
    }
}

