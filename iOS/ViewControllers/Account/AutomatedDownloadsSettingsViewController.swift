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
    let showManageHint: Bool
    let downloadSettings: AutomatedDownloadSettings

    private let cellReuseIdentifier = "SettingsOptionCell"
    private let destructiveCellReuseIdentifier = "DisableCell"

    private lazy var saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    private lazy var cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
    private lazy var waitBarButtonItem = UIBarButtonItem(customView: self.waitIndicator)

    private lazy var waitIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = Brand.default.colors.window
        return indicator
    }()

    init(course: Course, showManageHint: Bool = false) {
        self.course = course
        self.showManageHint = showManageHint
        self.downloadSettings = self.course.automatedDownloadSettings ?? AutomatedDownloadSettings()

        super.init(style: .insetGrouped)

        self.tableView.allowsMultipleSelection = true
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
        self.tableView.register(DestructiveTableViewCell.self, forCellReuseIdentifier: self.destructiveCellReuseIdentifier)

        self.setupTableHeaderView()
        self.tableView.tableHeaderView?.isHidden = true
        self.tableView.resizeTableHeaderView()

        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
    }

    private func setupTableHeaderView() {
        let label = UILabel()
        label.text = "Missing Permissions" // TODO: localization
        label.textColor = ColorCompatibility.systemRed
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center

        let buttonFont = UIFont.preferredFont(forTextStyle: .footnote)
        let attributedButtonText = NSMutableAttributedString(string: "Open Settings", attributes: [.font: buttonFont]) // TODO: localization

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationTitle = self.navigationController?.presentingViewController == nil ? course.title : "Automated Downloads"
        self.navigationItem.title = navigationTitle
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

    @objc private func save() {
        self.navigationItem.rightBarButtonItem = self.waitBarButtonItem
        self.waitIndicator.startAnimating()

        CourseHelper.setAutomatedDownloadSetting(forCourse: self.course, to: self.downloadSettings).onSuccess { [weak self] _ in
            self?.close()
        }.onSuccess {
            AutomatedDownloadsManager.scheduleNextBackgroundProcessingTask()
        }.onFailure { [weak self] error in
            self?.tableView.tableHeaderView?.isHidden = false
            UIView.animate(withDuration: defaultAnimationDurationUnlessReduceMotionEnabled) {
                self?.tableView.resizeTableHeaderView()
            }
        }.onComplete { [weak self] _ in
            self?.navigationItem.rightBarButtonItem = self?.saveBarButtonItem
        }
    }

    @objc private func openSettings() {
        Settings.open()
    }

    // data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return AutomatedDownloadSettings.DownloadOption.allCases.count
        case 1:
            return AutomatedDownloadSettings.MaterialTypes.allTypesWithTitle.count
        case 2:
            return AutomatedDownloadSettings.DeletionOption.allCases.count
        case 3:
            return self.course.automatedDownloadSettings != nil ? 1 : 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Material Types" // TODO: localize
        case 2:
            return "Deletion Policy" // TODO: localize
        default:
            return nil
        }

    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return self.downloadSettings.downloadOption.explanation
        case 2:
            return self.downloadSettings.deletionOption.explanation
        case 3:
            return self.showManageHint ? "You will be able to change these settings at any time via the course menu ('⋯') or under 'Downloaded Content' in the account tab." : nil // TODO: localize
        default:
            return nil
        }
    }

    // delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 {
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
            let (materialType, title) = AutomatedDownloadSettings.MaterialTypes.allTypesWithTitle[indexPath.row]
            cell.textLabel?.text = title
            cell.accessoryType = downloadSettings.materialTypes.contains(materialType) ? .checkmark : .none
        case 2:
            let deletionOption = AutomatedDownloadSettings.DeletionOption.allCases[indexPath.row]
            cell.textLabel?.text = deletionOption.title
            cell.accessoryType = deletionOption == downloadSettings.deletionOption ? .checkmark : .none
        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            // Disable Automated Downloads
            CourseHelper.setAutomatedDownloadSetting(forCourse: self.course, to: nil).onSuccess { [weak self] _ in
                AutomatedDownloadsManager.scheduleNextBackgroundProcessingTask()
                self?.close()
            }.onComplete { [weak self] _ in
                self?.navigationItem.rightBarButtonItem = self?.saveBarButtonItem
            }
            return
        }

        if indexPath.section == 1 {
            let materialType = AutomatedDownloadSettings.MaterialTypes.allTypesWithTitle[indexPath.row].type
            self.downloadSettings.materialTypes.formSymmetricDifference(materialType)
            self.tableView.reloadRows(at: [indexPath], with: .none)
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
        case 2:
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
            self.tableView.reloadRows(at: [oldRow, indexPath], with: .none)
        } else {
            let indexSet = IndexSet(integer: indexPath.section)
            self.tableView.reloadSections(indexSet, with: .none)
        }
    }

}
