//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

@available(iOS 13, *)
class AutomatedDownloadsSettingsViewController: UITableViewController {

    let course: Course
    let downloadSettings: AutomatedDownloadSettings

    private let cellReuseIdentifier = "SettingsOptionBasicCell"
    private let destructiveCellReuseIdentifier = "DisableCell"

    private lazy var saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    private lazy var cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
    private lazy var waitBarButtonItem = UIBarButtonItem(customView: self.waitIndicator)

    private lazy var waitIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = Brand.default.colors.window
        return indicator
    }()

    init(course: Course) {
        self.course = course
        self.downloadSettings = self.course.automatedDownloadSettings ?? AutomatedDownloadSettings()

        super.init(style: .insetGrouped)

        self.tableView.allowsMultipleSelection = true
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
        self.tableView.register(DestructiveTableViewCell.self, forCellReuseIdentifier: self.destructiveCellReuseIdentifier)

        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
    }

    @objc private func close() {
        if self.navigationController?.presentingViewController == nil {
            self.navigationController?.popViewController(animated: trueUnlessReduceMotionEnabled)
        } else {
            self.navigationController?.dismiss(animated: trueUnlessReduceMotionEnabled)
        }
    }

    @objc private func save() {
        self.navigationItem.rightBarButtonItem = self.waitBarButtonItem
        self.waitIndicator.startAnimating()

        CourseHelper.setAutomatedDownloadSetting(forCourse: self.course, to: self.downloadSettings).onSuccess { [weak self] _ in
            self?.close()
        }.onComplete { [weak self] _ in
            self?.navigationItem.rightBarButtonItem = self?.saveBarButtonItem
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSection = 2
        numberOfSection += self.course.automatedDownloadSettings != nil ? 1 : 0
        return numberOfSection
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return AutomatedDownloadSettings.DownloadOption.allCases.count
        case 1:
            return AutomatedDownloadSettings.DeletionOption.allCases.count
        case 2:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Deletion Policy"
        default:
            return nil
        }

    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return self.downloadSettings.downloadOption.explanation
        case 1:
            return self.downloadSettings.deletionOption.explanation
        default:
            return nil
        }
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.destructiveCellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = "Disable Automated Downloads"
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)

        switch indexPath.section {
        case 0:
            let downloadOption = AutomatedDownloadSettings.DownloadOption.allCases[indexPath.row]
            cell.textLabel?.text = downloadOption.title
            cell.accessoryType = downloadOption == downloadSettings.downloadOption ? .checkmark : .none
        case 1:
            let deletionOption = AutomatedDownloadSettings.DeletionOption.allCases[indexPath.row]
            cell.textLabel?.text = deletionOption.title
            cell.accessoryType = deletionOption == downloadSettings.deletionOption ? .checkmark : .none
        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            CourseHelper.setAutomatedDownloadSetting(forCourse: self.course, to: nil).onSuccess { [weak self] _ in
                self?.close()
            }.onComplete { [weak self] _ in
                self?.navigationItem.rightBarButtonItem = self?.saveBarButtonItem
            }
            return
        }

        var oldRow: Int?

        switch indexPath.section {
        case 0:
            let oldOption = self.downloadSettings.downloadOption
            let newOption = AutomatedDownloadSettings.DownloadOption.allCases[indexPath.row]
            if oldOption != newOption {
                self.downloadSettings.downloadOption = newOption
                oldRow = AutomatedDownloadSettings.DownloadOption.allCases.firstIndex(of: oldOption)
            }
        case 1:
            let oldOption = self.downloadSettings.deletionOption
            let newOption = AutomatedDownloadSettings.DeletionOption.allCases[indexPath.row]
            if oldOption != newOption {
                self.downloadSettings.deletionOption = newOption
                oldRow = AutomatedDownloadSettings.DeletionOption.allCases.firstIndex(of: oldOption)
            }
        default:
            break
        }

        self.switchSelectedSettingsCell(at: indexPath, to: oldRow)

        self.tableView.footerView(forSection: indexPath.section)?.textLabel?.text = self.tableView(tableView, titleForFooterInSection: indexPath.section)
        UIView.performWithoutAnimation {
            self.tableView.footerView(forSection: indexPath.section)?.sizeToFit()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
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
