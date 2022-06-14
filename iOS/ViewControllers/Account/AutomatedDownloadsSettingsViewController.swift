//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

@available(iOS 13, *)
class AutomatedDownloadsSettingsViewController: UITableViewController {

    let course: Course
    let downloadSettings: AutomatedDownloadSettings

    private let descriptionCellReuseIdentifier = "DescriptionCell"
    private let switchCellReuseIdentifier = "SwitchCell"
    private let optionCellReuseIdentifier = "SettingsOptionCell"

    private var persistedSettingsExist: Bool { self.course.automatedDownloadSettings != nil }
    private var backgroundDownloadEnabled: Bool { self.downloadSettings.newContentAction == .notificationAndBackgroundDownload }

    private lazy var doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))

    init(course: Course, showManageHint: Bool = false) {
        self.course = course

        let enableBackgroundDownloads = self.course.offersAutomatedBackgroundDownloads
        self.downloadSettings = self.course.automatedDownloadSettings ?? AutomatedDownloadSettings(enableBackgroundDownloads: enableBackgroundDownloads)

        super.init(style: .insetGrouped)

        self.tableView.allowsMultipleSelection = true
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(DescriptionTableViewCell.self, forCellReuseIdentifier: self.descriptionCellReuseIdentifier)
        self.tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: self.switchCellReuseIdentifier)
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.optionCellReuseIdentifier)

        self.setupTableHeaderView()
        self.tableView.tableHeaderView?.isHidden = true
        self.tableView.resizeTableHeaderView()

        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
    }

    private func setupTableHeaderView() {
        let label = UILabel()
        label.text = NSLocalizedString("automated-downloads.setup.message.failed",
                                       comment: "Automated Downloads (Setup): Message shown after failed setup")
        label.textColor = ColorCompatibility.systemRed
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center

        let buttonFont = UIFont.preferredFont(forTextStyle: .footnote)
        let buttonText = NSLocalizedString("global.button.title.open-settings", comment: "Button title to open settings app")
        let attributedButtonText = NSMutableAttributedString(string: buttonText, attributes: [.font: buttonFont])

        let symbolConfiguration = UIImage.SymbolConfiguration(font: buttonFont, scale: .small)
        let symbolImage = UIImage(systemName: "chevron.right", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = symbolImage
        attributedButtonText.append(NSAttributedString(attachment: imageAttachment))

        let button = UIButton()
        button.setAttributedTitle(attributedButtonText, for: .normal)
        button.setTitleColor(ColorCompatibility.secondaryLabel, for: .normal)
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = UIStackView.spacingUseDefault

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)

        let headerView = UIView()
        headerView.preservesSuperviewLayoutMargins = true
        headerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: headerView.topAnchor, multiplier: 2),
            headerView.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 2),
            stackView.leadingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.trailingAnchor),
        ])

        self.tableView.tableHeaderView = headerView
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.tableView.resizeTableHeaderView()
        }
    }

    @objc private func close() {
        if self.navigationController?.presentingViewController == nil {
            self.navigationController?.popViewController(animated: trueUnlessReduceMotionEnabled)
        } else {
            self.navigationController?.dismiss(animated: trueUnlessReduceMotionEnabled)
        }
    }

    @objc private func openSettings() {
        Settings.open()
    }

    // data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // description
            return 2
        case 1: // include slides
            return self.persistedSettingsExist ? 1 : 0
        case 2: // deletion policy
            return self.persistedSettingsExist && self.backgroundDownloadEnabled ? AutomatedDownloadSettings.DeletionOption.allCases.count : 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            let headerTitle = NSLocalizedString("automated-downloads.setup.header.content-deletion",
                                                comment: "Automated Downloads (Setup): Header title for the content deletion section")
            return self.persistedSettingsExist && self.backgroundDownloadEnabled ? headerTitle : nil
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("automated-downloads.setup.message.edit-again",
                                     comment: "Automated Downloads (Setup): Hint for the location of the settings view")
        case 1:
            return self.persistedSettingsExist ? self.downloadSettings.fileTypes.explanation : nil
        case 2:
            return self.persistedSettingsExist && self.backgroundDownloadEnabled ? self.downloadSettings.deletionOption.explanation : nil
        default:
            return nil
        }
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let someTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.descriptionCellReuseIdentifier, for: indexPath)
            guard let cell = someTableViewCell as? DescriptionTableViewCell else { return UITableViewCell() }
            cell.topMessageLabel.text = self.course.title
            cell.decorativeImages = self.downloadSettings.newContentAction.decorativeImages
            cell.titleLabel.text = self.downloadSettings.newContentAction.title
            cell.descriptionLabel.text = self.downloadSettings.newContentAction.explanation
            cell.selectionStyle = .none
            return cell
        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: self.switchCellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = NSLocalizedString("automated-downloads.setup.switch.title.activate",
                                                     comment: "Automated Downloads (Setup): Title for the activate switch")
            cell.selectionStyle = .none
            let cellSwitch = cell.accessoryView as? UISwitch
            cellSwitch?.isOn = self.persistedSettingsExist
            cellSwitch?.addTarget(self, action: #selector(valueOfActivateSwitchChanged(sender:)), for: .valueChanged)
            return cell
        case (1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: self.switchCellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = NSLocalizedString("automated-downloads.setup.switch.title.include-slides",
                                                     comment: "Automated Downloads (Setup): Title for the switch to include slides")
            cell.selectionStyle = .none
            let cellSwitch = cell.accessoryView as? UISwitch
            cellSwitch?.isOn = self.downloadSettings.fileTypes.contains(.slides)
            cellSwitch?.addTarget(self, action: #selector(valueOfIncludeSlidesSwitchChanged(sender:)), for: .valueChanged)
            return cell
        case (2, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: self.optionCellReuseIdentifier, for: indexPath)
            let deletionOption = AutomatedDownloadSettings.DeletionOption.allCases[indexPath.row]
            cell.textLabel?.text = deletionOption.title
            cell.accessoryType = deletionOption == self.downloadSettings.deletionOption ? .checkmark : .none
            return cell
        default:
            assertionFailure("Invalid index path")
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
        }

        if indexPath.section == 2 {
            let oldOption = self.downloadSettings.deletionOption
            let newOption = AutomatedDownloadSettings.DeletionOption.allCases[indexPath.row]
            if oldOption != newOption {
                self.downloadSettings.deletionOption = newOption
                if let row = AutomatedDownloadSettings.DeletionOption.allCases.firstIndex(of: oldOption) {
                    let oldIndexPath = IndexPath(row: row, section: indexPath.section)
                    self.tableView.reloadRows(at: [oldIndexPath, indexPath], with: .none)
                }
            }

            self.updateFooter(inSection: indexPath.section)
        }
    }

    @objc private func valueOfActivateSwitchChanged(sender: UISwitch) {
        let deleteSettings = !sender.isOn
        self.save(sender: sender, deleteSettings: deleteSettings).onSuccess { [weak self, course] _ in
            if deleteSettings {
                TrackingHelper.createEvent(.contentNotificationsDisabled, resourceType: .course, resourceId: course.id, on: self)
            } else {
                TrackingHelper.createEvent(.contentNotificationsEnabled, resourceType: .course, resourceId: course.id, on: self)
            }

            NewContentNotificationManager.renewNotifications(for: course)
            AutomatedDownloadsManager.scheduleNextBackgroundProcessingTask()
            AutomatedDownloadsManager.processPendingDownloadsAndDeletions(triggeredBy: .setup)
        }.onSuccess { _ in
            let sections = IndexSet(integersIn: 1...2)
            self.tableView.reloadSections(sections, with: .automatic)
        }
    }

    @objc private func valueOfIncludeSlidesSwitchChanged(sender: UISwitch) {
        if sender.isOn {
            self.downloadSettings.fileTypes.update(with: .slides)
        } else {
            self.downloadSettings.fileTypes.remove(.slides)
        }

        self.save(sender: sender).onSuccess { _ in
            self.updateFooter(inSection: 1)
        }
    }

    private func save(sender: UISwitch, deleteSettings: Bool = false) -> Future<Void, XikoloError> {
        sender.isEnabled = false

        let originalOnState = !sender.isOn
        let downloadSettings = deleteSettings ? nil : self.downloadSettings
        let result = CourseHelper.setAutomatedDownloadSetting(forCourse: self.course, to: downloadSettings).onComplete { [weak self] result in
            let isSuccess = result.value != nil
            self?.tableView.tableHeaderView?.isHidden = isSuccess
            UIView.animate(withDuration: defaultAnimationDurationUnlessReduceMotionEnabled) {
                self?.tableView.resizeTableHeaderView()
            }
        }.onFailure { _ in
            sender.isOn = originalOnState
        }.onComplete { _ in
            sender.isEnabled = true
        }

        return result
    }

    private func updateFooter(inSection section: Int) {
        self.tableView.footerView(forSection: section)?.textLabel?.text = self.tableView(tableView, titleForFooterInSection: section)
        UIView.performWithoutAnimation {
            self.tableView.footerView(forSection: section)?.sizeToFit()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

}
