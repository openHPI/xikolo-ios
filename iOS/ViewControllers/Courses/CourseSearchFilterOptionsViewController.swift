//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol CourseSearchFilterOptionsViewControllerDelegate: AnyObject {
    func setOptions(_ selectedOptions: Set<String>?, for filter: CourseSearchFilter)
}

class CourseSearchFilterOptionsViewController: UITableViewController {

    private let cellReuseIdentifier = "SearchFilterOptionItem"

    private lazy var selectAllBarButton: UIBarButtonItem = {
        let title = NSLocalizedString("global.list.selection.select all", comment: "Title for button for selecting all items in a list")
        return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(selectAllOptions))
    }()

    private lazy var deselectAllBarButton: UIBarButtonItem = {
        let title = NSLocalizedString("global.list.selection.deselect all", comment: "Title for button for deselecting all items in a list")
        return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(deselectAllOptions))
    }()

    let filter: CourseSearchFilter
    var options: [String]
    var selectedOptions: Set<String>
    weak var delegate: CourseSearchFilterOptionsViewControllerDelegate?

    init(filter: CourseSearchFilter, selectedOptions: Set<String>?, delegate: CourseSearchFilterOptionsViewControllerDelegate) {
        self.filter = filter
        self.delegate = delegate

        let options = filter.options()
        self.options = options

        let defaultOptions = filter.allOptionsActivatedByDefault ? Set(options) : Set([])
        self.selectedOptions = selectedOptions ?? defaultOptions

        if #available(iOS 13, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }

        self.tableView.allowsMultipleSelection = true
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("course-list.search.filter.options.title.refine serach",
                                                      comment: "Title for filter options menu")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = {
            let title = NSLocalizedString("course-list.search.filter.options.apply", comment: "Title for applying selected filter options")
            return UIBarButtonItem(title: title, style: .done, target: self, action: #selector(applyChanges))
        }()

        self.toolbarItems = [
            self.deselectAllBarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            self.selectAllBarButton,
        ]

        self.updateBarButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        let option = self.options[indexPath.row]
        let isSelected = self.selectedOptions.contains(option)

        cell.textLabel?.text = self.filter.displayName(forOption: option)
        cell.accessoryType = isSelected ? .checkmark : .none
        cell.selectionStyle = .none

        if isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.filter.title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = self.options[indexPath.row]
        self.selectedOptions.insert(option)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        self.updateBarButtons()
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let option = self.options[indexPath.row]
        self.selectedOptions.remove(option)
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        self.updateBarButtons()
    }

    @objc private func cancel() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func applyChanges() {
        let optionsCountOfDefaultSettings = self.filter.allOptionsActivatedByDefault ? self.options.count : 0
        if self.selectedOptions.count == optionsCountOfDefaultSettings {
            self.delegate?.setOptions(nil, for: self.filter)
        } else {
            self.delegate?.setOptions(self.selectedOptions, for: self.filter)
        }

        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func selectAllOptions() {
        for section in 0..<self.tableView.numberOfSections {
            for row in 0..<self.tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                self.tableView.selectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled, scrollPosition: .none)
                self.tableView(self.tableView, didSelectRowAt: indexPath)
            }
        }
    }

    @objc private func deselectAllOptions() {
        for section in 0..<self.tableView.numberOfSections {
            for row in 0..<self.tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                self.tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
                self.tableView(self.tableView, didDeselectRowAt: indexPath)
            }
        }
    }

    private func updateBarButtons() {
        let enableApplyButton = self.filter.allOptionsActivatedByDefault ? !self.selectedOptions.isEmpty : true
        self.navigationItem.rightBarButtonItem?.isEnabled = enableApplyButton
        self.selectAllBarButton.isEnabled = self.selectedOptions.count != self.options.count
        self.deselectAllBarButton.isEnabled = !self.selectedOptions.isEmpty
    }

}
