//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SwiftUI

@available(iOS 15, *)
struct QuizRecapView: View {
    let configuration: QuizRecapConfiguration
    let dismissAction: (() -> Void)
    let openItemForQuizQuestionAction: ((QuizQuestion) -> Void)

    @State var sessionId = UUID()

    @State var questionCounts: [QuizQuestion: Int]
    @State var correctlyAnsweredQuestions: Set<QuizQuestion>
    @State var remainingQuestions: [QuizQuestion]

    @State var totalQuestionCount: Int
    @State var errorCount: Int = 0
    var successCount: Int { self.correctlyAnsweredQuestions.count }

    var recapEnded: Bool { remainingQuestions.isEmpty && currentQuestion == nil }

    @State var currentQuestion: QuizQuestion? {
        didSet {
            allOptions = {
                guard let question = currentQuestion else { return [] }
                return question.shuffleOptions ? question.options.shuffled() : question.options
            }()
            revealedQuestionOptions = []
        }
    }
    @State var revealedQuestionOptions: Set<QuizQuestionOption> = []
    @State var allOptions: [QuizQuestionOption] = []

    func attributedFallbackText(for question: QuizQuestion) -> String? {
        guard let text = question.text else { return nil }
        let textFromAttributedString = MarkdownHelper.string(for: text)
        return textFromAttributedString.isEmpty ? nil : textFromAttributedString
    }

    /// We explicitly need to check for the IDs here, when the quiz is synced in the background
    /// the data for the options is renewed and this text would fail if we check for the whole object.
    var allCorrectOptionIds: Set<String> {
        Set(currentQuestion?.options.filter(\.correct).map(\.id) ?? [])
    }

    var allCorrectOptionsSelected: Bool {
        allCorrectOptionIds == Set(revealedQuestionOptions.map(\.id))
    }

    var questionEnded: Bool {
        allCorrectOptionsSelected || revealedQuestionOptions.contains(where: { !$0.correct })
    }

    @State var timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    @State var timeRemainingUntilNextQuestion: Int = 0

    init(configuration: QuizRecapConfiguration, dismissAction: @escaping () -> Void, openItemForQuizQuestionAction: @escaping (QuizQuestion) -> Void) {
        self.configuration = configuration
        self.dismissAction = dismissAction
        self.openItemForQuizQuestionAction = openItemForQuizQuestionAction
        let questions = Self.newQuestions(for: configuration)
        _remainingQuestions = State(initialValue: questions)
        _totalQuestionCount = State(initialValue: questions.count)
        _questionCounts = State(initialValue: [:])
        _correctlyAnsweredQuestions = State(initialValue: [])

        let overallQuestionCount = Self.allEligibleQuestions(for: configuration).count
        self.track(.quizRecapStarted, with: [
            "questions_count": String(questions.count),
            "questions_total": String(overallQuestionCount),
            "only_visited_items": String(configuration.onlyVisitedItems),
            "section_ids": configuration.sectionIds.joined(separator: ","),
        ])
    }

    static func allEligibleQuestions(for configuration: QuizRecapConfiguration) -> [QuizQuestion] {
        let courseFetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: configuration.courseId)
        guard let course = CoreDataHelper.viewContext.fetchSingle(courseFetchRequest).value else { return [] }

        let questionsFetchRequest = QuizQuestionHelper.FetchRequest.questionsForRecap(in: course,
                                                                                      limitedToSectionsWithIds: configuration.sectionIds,
                                                                                      onlyVisitedItems: configuration.onlyVisitedItems)

        return CoreDataHelper.viewContext.fetchMultiple(questionsFetchRequest).value ?? []
    }

    static func newQuestions(for configuration: QuizRecapConfiguration) -> [QuizQuestion] {
        let questions = self.allEligibleQuestions(for: configuration)
        let endIndex = min(questions.count, configuration.questionLimit ?? questions.count)
        return Array(questions.shuffled()[..<endIndex])
    }

    func loadNewQuestionSet() {
        let questions = Self.newQuestions(for: configuration)
        self.sessionId = UUID()
        self.remainingQuestions = questions
        self.totalQuestionCount = questions.count
        self.questionCounts = [:]
        self.correctlyAnsweredQuestions = Set()
        self.errorCount = 0
        loadNewQuestion()

        let overallQuestionCount = Self.allEligibleQuestions(for: configuration).count
        self.track(.quizRecapStarted, with: [
            "questions_count": String(questions.count),
            "questions_total": String(overallQuestionCount),
            "only_visited_items": String(configuration.onlyVisitedItems),
            "section_ids": configuration.sectionIds.joined(separator: ","),
        ])
    }

    var stopButton: some View {
        Button {
            remainingQuestions = []
            currentQuestion = nil

            self.track(.quizRecapStopped, with: [
                "correct_count": String(self.successCount),
                "wrong_count": String(self.errorCount),
                "stopped_by_user": String(true),
            ])
        } label: {
            HStack {
                Image(systemName: "stop.fill")
                Text("quiz-recap.button.stop", tableName: "Localizable-SwiftUI")
            }
            .font(.body)
            .foregroundColor(.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(999)
        }
    }

    var closeButton: some View {
        Button {
            dismissAction()
        } label: {
            Image(systemName: "xmark")
                .font(.body)
                .foregroundColor(.primary)
                .padding(6)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(999)
        }
    }

    var topInfo: some View {
        HStack(spacing: 24) {
            HStack {
                Image(systemName: "xmark.diamond")
                Text("\(errorCount)")
            }
            .foregroundColor(!recapEnded && questionEnded && !allCorrectOptionsSelected ? .red : .primary)

            HStack {
                Image(systemName: "checkmark.seal.fill")
                Text("\(successCount)/\(totalQuestionCount)")
            }
            .foregroundColor(!recapEnded && questionEnded && allCorrectOptionsSelected ? .green : .primary)
        }
        .font(.footnote.monospaced())
        .frame(height: 22)
    }

    var questionEndView: some View {
        VStack {
            ZStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .opacity(questionEnded && allCorrectOptionsSelected ? 1 : 0)
                Image(systemName: "xmark.diamond.fill")
                    .foregroundColor(.red)
                    .opacity(questionEnded && !allCorrectOptionsSelected ? 1 : 0)
            }
            .font(.system(size: 48))
        }
    }

    func questionDescription(for question: QuizQuestion) -> some View {
        VStack(spacing: 8) {
            if let sectionTitle = question.quiz?.item?.section?.title {
                Text(sectionTitle)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }

            if let attributedFallbackQuestionText = attributedFallbackText(for: question), attributedFallbackQuestionText != question.text {
                Text(attributedFallbackQuestionText)
                    .font(.body)
                    .fontWeight(.medium)
            } else {
                Text(question.text ?? "")
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }

            Group {
                switch(question.questionType) {
                case .singleAnswer:
                    Text("quiz-recap.answer-options.single-select.explanation", tableName: "Localizable-SwiftUI")
                case .multipleAnswer:
                    Text("quiz-recap.answer-options.multi-answer.explanation", tableName: "Localizable-SwiftUI")
                default:
                    EmptyView()
                }
            }
            .font(.callout)
            .modify {
                if #available(iOS 16.0, *) {
                    $0.fontWeight(.medium)
                }
            }
            .foregroundColor(.secondary)
        }
    }

    var questionOptions: some View {
        VStack {
            ForEach(allOptions, id: \.id) { option in
                QuestionOptionView(option: option, selected: .constant( revealedQuestionOptions.contains(option)), questionEnded: .constant(questionEnded))
                    .onTapGesture {
                        evaluateSelection(of: option)
                    }
            }
        }
    }

    var sparkles: some View {
        ZStack {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .frame(maxWidth: 150, maxHeight: 90, alignment: .center)

            Image(systemName: "sparkle")
                .font(.system(size: 30))
                .frame(maxWidth: 150, maxHeight: 90, alignment: .topLeading)
                .padding(.horizontal)

            Image(systemName: "sparkle")
                .font(.system(size: 10))
                .frame(maxWidth: 150, maxHeight: 90, alignment: .leading)

            Image(systemName: "sparkle")
                .font(.system(size: 25))
                .frame(maxWidth: 150, maxHeight: 90, alignment: .bottomTrailing)

            Image(systemName: "sparkle")
                .font(.system(size: 15))
                .frame(maxWidth: 150, maxHeight: 90, alignment: .trailing)
        }
        .foregroundColor(.yellow)
    }

    var summary: some View {
        VStack(spacing: 16) {
            sparkles

            VStack(spacing: 16) {
                Text("quiz-recap.end-screen.headline", tableName: "Localizable-SwiftUI")
                    .font(.headline)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text("quiz-recap.end-screen.description \(successCount) \(successCount + errorCount)", tableName: "Localizable-SwiftUI")
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 24) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("\(successCount)")
                    }
                    .foregroundColor(.green.darker(by: 0.2))

                    HStack {
                        Image(systemName: "xmark.diamond.fill")
                        Text("\(errorCount)")
                    }
                    .foregroundColor(errorCount == 0 ? .secondary : .red.darker(by: 0.2))
                }
                .imageScale(.large)
                .font(.system(size: 20, weight: .medium).monospacedDigit())
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
    }

    var restartButton: some View {
        Button {
            loadNewQuestionSet()
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                if let questionLimit = configuration.questionLimit {
                    Text("quiz-recap.button.restart-with-questions \(questionLimit)", tableName: "Localizable-SwiftUI")
                } else {
                    Text("quiz-recap.button.restart", tableName: "Localizable-SwiftUI")
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
        }
        .modify {
            if #available(iOS 16, *) {
                $0.fontWeight(.medium)
            }
        }
        .foregroundColor(Color.white)
        .background(Color.orange)
        .cornerRadius(100)
    }

    var answeredQuestionsSummary: some View {
        VStack {
            Spacer(minLength: 12)
            VStack(alignment: .leading) {
                ForEach(questionCounts.sorted(by: { a, b in
                    if a.1 == b.1 { return !correctlyAnsweredQuestions.contains(a.0) && correctlyAnsweredQuestions.contains(b.0) }
                    return a.1 > b.1
                }), id: \.key) { question, count in
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: correctlyAnsweredQuestions.contains(question) ? "checkmark.seal.fill" : "xmark.diamond.fill")
                                .foregroundColor(correctlyAnsweredQuestions.contains(question) ? .green : .red)
                            Text("\(count)")
                        }
                        .font(.footnote.monospaced())

                        Text(attributedFallbackText(for: question) ?? question.text ?? "")
                            .lineLimit(3)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .contentShape(Rectangle())
                    .padding(.vertical, 4)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        self.openItemForQuizQuestionAction(question)
                    }

                    Divider()
                }
            }
        }
    }

    var body: some View {
        Group {
            if let currentQuestion = currentQuestion, !recapEnded {
                VStack {
                    HStack {
                        stopButton
                        Spacer()
                        topInfo
                    }
                    .padding()

                    ScrollView {
                        VStack(spacing: 24) {
                            questionEndView
                            questionDescription(for: currentQuestion)
                            questionOptions

                            Text("quiz-recap.prompt.next-question \(timeRemainingUntilNextQuestion + 1)", tableName: "Localizable-SwiftUI")
                                .font(.callout.monospacedDigit())
                                .foregroundColor(.secondary)
                                .opacity(questionEnded && !remainingQuestions.isEmpty && timeRemainingUntilNextQuestion < 3 ? 1 : 0)
                        }
                        .frame(maxWidth: 600)
                        .padding(.horizontal)
                    }
                }
            } else {
                VStack {
                    HStack {
                        closeButton
                        Spacer()
                    }
                    .padding()

                    ScrollView {
                        VStack(spacing: 24) {
                            summary
                            VStack {
                                restartButton

                                Button {
                                    dismissAction()
                                } label: {
                                    Text("quiz-recap.button.more-options", tableName: "Localizable-SwiftUI")
                                    Image(systemName: "chevron.forward")
                                        .imageScale(.small)
                                }
                            }
                            answeredQuestionsSummary
                        }
                        .frame(maxWidth: 600)
                        .padding(.horizontal)
                    }
                }

            }
        }
        .background(Color(UIColor.systemBackground), ignoresSafeAreaEdges: .all)
        .navigationBarHidden(true)
        .onAppear {
            loadNewQuestion()
        }
        .onReceive(timer) { _ in
            guard questionEnded else { return }
            if timeRemainingUntilNextQuestion > 0 {
                timeRemainingUntilNextQuestion -= 1
            } else {
                loadNewQuestion()
            }
        }
    }

    func loadNewQuestion() {
        timer.upstream.connect().cancel()
        currentQuestion = remainingQuestions.first

        if currentQuestion == nil {
            self.track(.quizRecapStopped, with: [
                "correct_count": String(self.successCount),
                "wrong_count": String(self.errorCount),
                "stopped_by_user": String(false),
            ])
        }
    }

    func evaluateSelection(of option: QuizQuestionOption) {
        guard !questionEnded else { return }

        revealedQuestionOptions.insert(option)

        if questionEnded, let currentQuestion = currentQuestion {
            questionCounts[currentQuestion, default: 0] += 1
            self.track(.quizRecapQuestionAnswered, with: [
                "question_id": currentQuestion.id,
                "correct": String(allCorrectOptionsSelected),
            ])

            if allCorrectOptionsSelected {
                timeRemainingUntilNextQuestion = 1
                correctlyAnsweredQuestions.insert(currentQuestion)
                remainingQuestions.removeFirst()
            } else {
                timeRemainingUntilNextQuestion = 3
                errorCount += 1
                remainingQuestions.removeFirst()

                // Re-insert incorrectly answered question up to three times
                if questionCounts[currentQuestion, default: 0] < 3 {
                    let newIndex = min(Int.random(in: 5...10), remainingQuestions.count)
                    remainingQuestions.insert(currentQuestion, at: newIndex)
                }
            }

            timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
        }
    }

    func track(_ verb: TrackingHelper.AnalyticsVerb, with context: [String: String?]) {
        var recapContext = context
        recapContext["recap_session_id"] = self.sessionId.uuidString
        TrackingHelper.createEvent(verb, resourceType: .course, resourceId: configuration.courseId, on: nil, context: recapContext)
    }

}
