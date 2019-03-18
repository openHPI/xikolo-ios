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

    let filter: CourseSearchFilter
    var options: [String]
    var selectedOptions: Set<String>
    weak var delegate: CourseSearchFilterOptionsViewControllerDelegate?

    init(filter: CourseSearchFilter, selectedOptions: Set<String>?, delegate: CourseSearchFilterOptionsViewControllerDelegate) {
        self.filter = filter
        self.delegate = delegate

        let options = filter.options
        self.options = options
        self.selectedOptions = selectedOptions ?? Set(options)

        super.init(style: .grouped)

        self.tableView.allowsMultipleSelection = true
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Refine search"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(applyChanges))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filter.options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        let title = self.options[indexPath.row]
        let isSelected = self.selectedOptions.contains(title)
        cell.textLabel?.text = title
        cell.accessoryType = isSelected ? .checkmark : .none
        cell.selectedBackgroundView = UIView()

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
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let option = self.options[indexPath.row]
        self.selectedOptions.remove(option)
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

    @objc private func cancel() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func applyChanges() {
        if self.selectedOptions.count == self.options.count {
            self.delegate?.setOptions(nil, for: self.filter)
        } else {
            self.delegate?.setOptions(self.selectedOptions, for: self.filter)
        }

        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}