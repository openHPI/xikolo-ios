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

    @IBOutlet var contentViews: [UIView]!
    @IBOutlet var loadingViews: [UIView]!

    @IBOutlet private weak var startButtonShort: UIButton!
    @IBOutlet private weak var startButtonMedium: UIButton!
    @IBOutlet private weak var startButtonLong: UIButton!
    @IBOutlet private weak var startButtonComplete: UIButton!
    @IBOutlet private weak var optionsLabel: UILabel!

    private weak var delegate: CourseAreaViewControllerDelegate?
    private var course: Course!

    private var considerOnlyVisitedItems: Bool = false {
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
        self.refresh()

        self.scrollView.delegate = self
        self.scrollView.alwaysBounceVertical = true
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
                return "Only questions from self-test items that you have visited will be tested."
            } else {
                return "Questions from all self-test items will be tested, regardless if you visited the item or not."
            }
        }()

        let part2 = {
            if course.sectionsForQuizRecap.map(\.id).allSatisfy({ sections.contains($0) }) {
                return "Self-test questions from all available course sections (\(course.sectionsForQuizRecap.count)) will be considered."
            }

            let joinedCourseSectionTitles = course.sectionsForQuizRecap
                .filter { sections.contains($0.id) }
                .sorted(by: \.position)
                .compactMap(\.title)
                .lazy.joined(separator: ", ")
            return "Only \(sections.count) course section(s) will be considered: " + joinedCourseSectionTitles
        }()

        self.optionsLabel.text = [part1, part2].joined(separator: "\n")
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
            buttonConfig?.subtitle = "\(questionCount) questions"
            self.startButtonComplete.configuration = buttonConfig
        }
    }

    @IBAction func openOptionsMenu() {
        let optionsViewController = QuizRecapOptionsViewController(course: course,
                                                                   selectedSections: self.sections,
                                                                   considerOnlyVisitedItems: self.considerOnlyVisitedItems,
                                                                   delegate: self)
        let navigationController = UINavigationController(rootViewController: optionsViewController)
        navigationController.modalPresentationStyle = .formSheet
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction func startShortRecapSession() {
        self.startRecapSession(withQuestionLimit: 10)
    }

    @IBAction func startMediumRecapSession() {
        self.startRecapSession(withQuestionLimit: 20)
    }

    @IBAction func startLongRecapSession() {
        self.startRecapSession(withQuestionLimit: 50)
    }

    @IBAction func startCompleteRecapSession() {
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
