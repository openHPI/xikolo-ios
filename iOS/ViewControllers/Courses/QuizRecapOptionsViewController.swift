//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

protocol QuizRecapOptionsViewControllerDelegate: AnyObject {
    func setOptions(sections: Set<String>, considerOnlyVisitedItems: Bool)
}

class QuizRecapOptionsViewController: UITableViewController {

    private let cellReuseIdentifierSection = "CourseSectionOptionItem"
    private let cellReuseIdentifierVisited = "VisitedOptionItem"

    private lazy var selectAllBarButton: UIBarButtonItem = {
        let title = NSLocalizedString("global.list.selection.select all", comment: "Title for button for selecting all items in a list")
        return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(selectAllOptions))
    }()

    private lazy var deselectAllBarButton: UIBarButtonItem = {
        let title = NSLocalizedString("global.list.selection.deselect all", comment: "Title for button for deselecting all items in a list")
        return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(deselectAllOptions))
    }()

    private let course: Course
    private var courseSections: [CourseSection] {
        return course.sectionsForQuizRecap.sorted(by: \.position)
    }

    private var selectedSections: Set<String>
    private var considerOnlyVisitedItems: Bool

    private weak var delegate: QuizRecapOptionsViewControllerDelegate?

    init(course: Course, selectedSections: Set<String>, considerOnlyVisitedItems: Bool, delegate: QuizRecapOptionsViewControllerDelegate) {
        self.course = course
        self.selectedSections = selectedSections
        self.considerOnlyVisitedItems = considerOnlyVisitedItems
        self.delegate = delegate

        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }

        self.tableView.allowsMultipleSelection = true
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifierSection)
        self.tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifierVisited)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("quiz-recap.settings.title", comment: "Title for the setting view for the quiz recap")
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.courseSections.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifierSection, for: indexPath)
            let section = self.courseSections[indexPath.row]
            let isSelected = self.selectedSections.contains(section.id)

            cell.textLabel?.text = self.courseSections[indexPath.row].title
            cell.accessoryType = isSelected ? .checkmark : .none
            cell.selectionStyle = .none

            if isSelected {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifierVisited, for: indexPath)
            cell.textLabel?.text = NSLocalizedString("quiz-recap.settings.option.consider-only-visited-items",
                                                     comment: "Title for the quiz recap setting option to consider only visited items")
            cell.selectionStyle = .none
            let cellSwitch = cell.accessoryView as? UISwitch
            cellSwitch?.isOn = self.considerOnlyVisitedItems
            cellSwitch?.addTarget(self, action: #selector(valueOfVisitedSwitchChanged(sender:)), for: .valueChanged)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? NSLocalizedString("quiz-recap.settings.section-title.course sections", comment: "Section title for course sections") : nil
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        let sectionsWithNotVisitedSelfTests = self.courseSections.filter(\.containsUnvisitedItemsForQuizRecap)
        if sectionsWithNotVisitedSelfTests.isEmpty {
            return NSLocalizedString("quiz-recap.settings.explanation.all-self-test-visited",
                                     comment: "Explanation when all self test have been visited")
        } else {
            let format = NSLocalizedString("quiz-recap.settings.explanation.some-self-tests-not-visited",
                                           comment: "Format: Explanation when some self test have not been visited")
            return String(format: format, sectionsWithNotVisitedSelfTests.count, sectionsWithNotVisitedSelfTests.compactMap(\.title).joined(separator: ", "))
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let section = self.courseSections[indexPath.row]
        self.selectedSections.insert(section.id)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        self.updateBarButtons()
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let section = self.courseSections[indexPath.row]
        self.selectedSections.remove(section.id)
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        self.updateBarButtons()
    }

    @objc private func cancel() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func applyChanges() {
        let sections = self.courseSections.map(\.id).allSatisfy({ self.selectedSections.contains($0) }) ? [] : self.selectedSections
        self.delegate?.setOptions(sections: sections, considerOnlyVisitedItems: considerOnlyVisitedItems)
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func valueOfVisitedSwitchChanged(sender: UISwitch) {
        self.considerOnlyVisitedItems = sender.isOn
    }

    @objc private func selectAllOptions() {
        for section in 0..<1 {
            for row in 0..<self.tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                self.tableView.selectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled, scrollPosition: .none)
                self.tableView(self.tableView, didSelectRowAt: indexPath)
            }
        }
    }

    @objc private func deselectAllOptions() {
        for section in 0..<1 {
            for row in 0..<self.tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                self.tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
                self.tableView(self.tableView, didDeselectRowAt: indexPath)
            }
        }
    }

    private func updateBarButtons() {
        self.navigationItem.rightBarButtonItem?.isEnabled = !self.selectedSections.isEmpty
        self.selectAllBarButton.isEnabled = self.selectedSections.count != self.courseSections.count
        self.deselectAllBarButton.isEnabled = !self.selectedSections.isEmpty
    }

}
