//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class HelpdeskTicketTopicListViewController: UITableViewController {

    typealias CompletionHandler = ((HelpdeskTicket.Topic) -> Void)

    private let cellReuseIdentifier = "topicCell"

    private lazy var courses: [Course] = {
        let result = CoreDataHelper.viewContext.fetchMultiple(CourseHelper.FetchRequest.visibleCourses)
        return result.value ?? []
    }()

    let selectedTopic: HelpdeskTicket.Topic
    let completionHandler: CompletionHandler

    init(selectedTopic: HelpdeskTicket.Topic, completionHandler: @escaping CompletionHandler) {
        self.selectedTopic = selectedTopic
        self.completionHandler = completionHandler

        if #available(iOS 13, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }

        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Topic"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // generic section
            return HelpdeskTicket.Topic.genericTopics.filter(\.isAvailable).count
        } else { // course specific section
            return self.courses.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        let topic = self.topic(for: indexPath)
        cell.textLabel?.text = topic.displayName
        cell.accessoryType = topic == self.selectedTopic ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("helpdesk.category.general", comment: "helpdesk category general questions")
        } else {
            return NSLocalizedString("helpdesk.category.course-specific", comment: "helpdesk category course-specific questions")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = self.topic(for: indexPath)
        self.completionHandler(topic)
        self.cancel()
    }

    private func topic(for indexPath: IndexPath) -> HelpdeskTicket.Topic {
        if indexPath.section == 0 {
            return HelpdeskTicket.Topic.genericTopics.filter(\.isAvailable)[indexPath.row]
        } else {
            let course = self.courses[indexPath.row]
            return .courseSpecific(course)
        }
    }

    @objc private func cancel() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}
