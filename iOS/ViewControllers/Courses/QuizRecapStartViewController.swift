//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

struct QuizRecapConfiguration {
    let courseId: String
    let sectionIds: Set<String>
    let onlyVisitedItems: Bool
    let questionLimit: Int?
}

class QuizRecapStartViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private var contentViews: [UIView]!
    @IBOutlet private var loadingViews: [UIView]!

    @IBOutlet private weak var startButtonShort: UIButton!
    @IBOutlet private weak var startButtonMedium: UIButton!
    @IBOutlet private weak var startButtonLong: UIButton!
    @IBOutlet private weak var startButtonComplete: UIButton!
    @IBOutlet private weak var optionsLabel: UILabel!
    @IBOutlet private weak var optionsIndicator: UIView!

    private weak var delegate: CourseAreaViewControllerDelegate?
    private var course: Course!

    private var considerOnlyVisitedItems = false {
        didSet {
            self.updateView()
        }
    }
    private var selectedSections: Set<String> = [] {
        didSet {
            self.updateView()
        }
    }

    private var sections: Set<String> {
        return selectedSections.isEmpty ? Set(course.sectionsForQuizRecap.map(\.id)) : selectedSections
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateView()

        self.addRefreshControl()

        self.scrollView.delegate = self
        self.scrollView.alwaysBounceVertical = true

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDefaults.standard.setQuizRecapNoticed(to: true, in: self.course)
        NotificationCenter.default.post(name: UserDefaults.quizRecapNoticedNotificationName, object: self.course.id)
    }

    func updateView() {
        let loaded = !self.course.sectionsForQuizRecap.isEmpty
        if loaded {
            self.updateSettingsSubtitle()
            self.updateStartButtons()
        }

        self.contentViews.forEach { $0.isHidden = !loaded }
        self.loadingViews.forEach { $0.isHidden = loaded }
    }

    func updateSettingsSubtitle() {
        let part1 = {
            if self.considerOnlyVisitedItems {
                return NSLocalizedString("quiz-recap.settings-summary.consider-only-visited-item.true",
                                         comment: "Text to appear in the settings summary for the quiz recap if only visited items should be considered.")
            } else {
                return NSLocalizedString("quiz-recap.settings-summary.consider-only-visited-item.false",
                                         comment: "Text to appear in the settings summary for the quiz recap if not only visited items should be considered.")
            }
        }()

        let part2 = {
            if self.course.sectionsForQuizRecap.map(\.id).allSatisfy({ sections.contains($0) }) {
                let format = NSLocalizedString("quiz-recap.settings-summary.section-names.all",
                                         comment: "Format: Text to appear in the settings summary for the quiz recap when all course sections are considered.")
                return String(format: format, self.course.sectionsForQuizRecap.count)
            }

            let joinedCourseSectionTitles = self.course.sectionsForQuizRecap
                .filter { self.sections.contains($0.id) }
                .sorted(by: \.position)
                .compactMap(\.title)
                .lazy.joined(separator: ", ")
            let format = NSLocalizedString("quiz-recap.settings-summary.section-names.some",
                                           comment: "Format: Text to appear in the settings summary for the quiz recap when only some course sections are considered.")
            return String(format: format, self.sections.count, joinedCourseSectionTitles)
        }()

        self.optionsLabel.text = [part1, part2].joined(separator: "\n")
        self.optionsIndicator.isHidden = !self.considerOnlyVisitedItems && self.course.sectionsForQuizRecap.map(\.id).allSatisfy { self.sections.contains($0) }
    }

    func updateStartButtons() {
        let fetchRequest = QuizQuestionHelper.FetchRequest.questionsForRecap(in: self.course,
                                                                             limitedToSectionsWithIds: self.sections,
                                                                             onlyVisitedItems: self.considerOnlyVisitedItems)
        let questionCount = CoreDataHelper.viewContext.fetchMultiple(fetchRequest).value?.count ?? 0 // TODO: Improve performance

        self.startButtonLong.isHidden = questionCount <= 50
        self.startButtonMedium.isHidden = questionCount <= 20
        self.startButtonShort.isHidden = questionCount <= 10

        if #available(iOS 15, *) {
            var buttonConfig = self.startButtonComplete.configuration
            let format = NSLocalizedString("quiz-recap.start-button.subtitle", comment: "Format: Subtitle for the start buttons for the quiz recap")
            buttonConfig?.subtitle = String(format: format, questionCount)
            self.startButtonComplete.configuration = buttonConfig
        }
    }

    @IBAction private func openOptionsMenu() {
        let optionsViewController = QuizRecapOptionsViewController(course: course,
                                                                   selectedSections: self.sections,
                                                                   considerOnlyVisitedItems: self.considerOnlyVisitedItems,
                                                                   delegate: self)
        let navigationController = UINavigationController(rootViewController: optionsViewController)
        navigationController.modalPresentationStyle = .formSheet
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func startShortRecapSession() {
        self.startRecapSession(withQuestionLimit: 10)
    }

    @IBAction private func startMediumRecapSession() {
        self.startRecapSession(withQuestionLimit: 20)
    }

    @IBAction private func startLongRecapSession() {
        self.startRecapSession(withQuestionLimit: 50)
    }

    @IBAction private func startCompleteRecapSession() {
        self.startRecapSession()
    }

    func startRecapSession(withQuestionLimit questionLimit: Int? = nil) {
        guard #available(iOS 15, *) else { return }
        let configuration = QuizRecapConfiguration(courseId: self.course.id,
                                                   sectionIds: self.sections,
                                                   onlyVisitedItems: self.considerOnlyVisitedItems,
                                                   questionLimit: questionLimit)
        let quizRecapViewController = QuizRecapViewController(configuration: configuration)
        let navigationController = UINavigationController(rootViewController: quizRecapViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func coreDataChange(notification: Notification) {
        // Workaround for when visiting the quiz recap before quizzes have been loaded for the first time
        if notification.includesChanges(for: Quiz.self) || notification.includesChanges(for: QuizQuestion.self) {
            self.updateView()
        }
    }

}

extension QuizRecapStartViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidScroll(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidEndDecelerating(scrollView)
    }

}

extension QuizRecapStartViewController: RefreshableViewController {

    var refreshableScrollView: UIScrollView {
        return self.scrollView
    }

    func refreshingAction() -> Future<Void, XikoloError> {
        return QuizHelper.syncQuizzes(forCourse: self.course).asVoid()
    }

    func didRefresh() {
        self.updateView()
    }

}

extension QuizRecapStartViewController: QuizRecapOptionsViewControllerDelegate {
    func setOptions(sections: Set<String>, considerOnlyVisitedItems: Bool) {
        self.selectedSections = sections
        self.considerOnlyVisitedItems = considerOnlyVisitedItems
    }
}

extension QuizRecapStartViewController: CourseAreaViewController {
    var area: CourseArea { .recap }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(self.area == area)
        self.course = course
        self.delegate = delegate
    }

}

extension Course {
    var sectionsForQuizRecap: Set<CourseSection> {
        return self.sections.filter(\.containsItemsForQuizRecap)
    }
}

extension CourseSection {
    var containsItemsForQuizRecap: Bool {
        return self.items.contains(where: { $0.eligibleForQuizRecap }) && self.startsAt?.inPast ?? true
    }

    var containsUnvisitedItemsForQuizRecap: Bool {
        return self.items.contains(where: { $0.eligibleForQuizRecap && !$0.visited }) && self.startsAt?.inPast ?? true
    }
}

extension CourseItem {
    var eligibleForQuizRecap: Bool {
        guard self.contentType == "quiz" && self.exerciseType == "selftest" else { return false }
        guard let quiz = self.content as? Quiz else { return false }
        return quiz.questions.contains { $0.eligibleForRecap == true }
    }
}
