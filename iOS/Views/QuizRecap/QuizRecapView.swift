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
    @State var totalQuestionCount: Int

    @State var remainingQuestions: [QuizQuestion]
    @State var correctlyAnsweredQuestions: [QuizQuestion] = []
    @State var incorrectlyAnsweredQuestions: [QuizQuestion] = []

    var successCount: Int { correctlyAnsweredQuestions.count }
    var errorCount: Int { incorrectlyAnsweredQuestions.count }

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

    var attributedFallbackQuestionText: String? {
        guard let text = currentQuestion?.text else { return nil }
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

    init(configuration: QuizRecapConfiguration, dismissAction: @escaping () -> Void) {
        self.configuration = configuration
        self.dismissAction = dismissAction
        let questions = Self.newQuestions(for: configuration)
        _totalQuestionCount = State(initialValue: questions.count)
        _remainingQuestions = State(initialValue: questions)
    }

    static func newQuestions(for configuration: QuizRecapConfiguration) -> [QuizQuestion] {
        let courseFetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: configuration.courseId)
        guard let course = CoreDataHelper.viewContext.fetchSingle(courseFetchRequest).value else { return [] }

        let questionsFetchRequest = QuizQuestionHelper.FetchRequest.questionsForRecap(in: course,
                                                                             limitedToSectionsWithIds: configuration.sectionIds,
                                                                             onlyVisitedItems: configuration.onlyVisitedItems)

        guard let questions = CoreDataHelper.viewContext.fetchMultiple(questionsFetchRequest).value else { return [] }

        let endIndex = min(questions.count, configuration.questionLimit ?? questions.count)
        return Array(questions.shuffled()[..<endIndex])
    }

    func loadNewQuestionSet() {
        let questions = Self.newQuestions(for: configuration)
        self.totalQuestionCount = questions.count
        self.remainingQuestions = questions
        self.correctlyAnsweredQuestions = []
        self.incorrectlyAnsweredQuestions = []
        loadNewQuestion()
    }

    var stopButton: some View {
        Button {
            remainingQuestions = []
            currentQuestion = nil
        } label: {
            HStack {
                Image(systemName: "stop.fill")
                Text("Stop")
            }
            .font(.body)
            .foregroundColor(.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(999)
        }
        .padding()
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
        .padding()
    }

    var topInfo: some View {
        Group {
            if !recapEnded {
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
                .padding()
            }
        }
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
            if let attributedFallbackQuestionText = attributedFallbackQuestionText, attributedFallbackQuestionText != currentQuestion?.text {
                Text(attributedFallbackQuestionText)
                    .font(.body)
                    .fontWeight(.medium)
            } else {
                Text(currentQuestion?.text ?? "")
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }

            Group {
                switch(question.questionType) {
                case .singleAnswer:
                    Text("Select the correct answer")
                case .multipleAnswer:
                    Text("One or more answers might be correct")
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
        .padding(.horizontal, 24)
    }

    var shimmeringSparkles: some View {
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
        .shimmer()
    }

    var summary: some View {
        VStack(spacing: 16) {
            shimmeringSparkles

            VStack(spacing: 16) {
                Text("Quiz abgeschlossen!")
                    .font(.headline)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                Text("Glückwunsch, Sie haben \(successCount) Fragen in insgesamt \(successCount + errorCount) Versuchen beantwortet.")
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)

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
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
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
                    Text("Restart with \(questionLimit) new questions")
                } else {
                    Text("Restart")
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

    var incorrectlyAnsweredQuestionsSummary: some View {
        Group {
            if !incorrectlyAnsweredQuestions.isEmpty {
                Spacer(minLength: 12)
                VStack(alignment: .leading) {
                    Text("Incorrectly answered questions")
                        .font(.subheadline)
                    let grouped = incorrectlyAnsweredQuestions.reduce(into: [:]) { result, character in
                        result[character, default: 0] += 1
                    }
                    ForEach(grouped.sorted(by: { a, b in
                        return a.1 > b.1
                    }), id: \.key) { question, count in
                        HStack {
                            Text(question.text ?? "")
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.diamond")
                                Text("\(count)")
                            }
                            .font(.footnote.monospaced())
                            Image(systemName: "arrow.right")
                        }
                        .padding(.vertical, 4)
                        .foregroundColor(.secondary)

                        Divider()
                    }
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

                    ScrollView {
                        VStack(spacing: 24) {
                            questionEndView
                            questionDescription(for: currentQuestion)
                            questionOptions

                            Text("Next question in \( timeRemainingUntilNextQuestion + 1)...")
                                .font(.callout.monospacedDigit())
                                .foregroundColor(.secondary)
                                .opacity(questionEnded && !remainingQuestions.isEmpty && timeRemainingUntilNextQuestion < 3 ? 1 : 0)

                        }
                        .frame(maxWidth: 600, minHeight: 400)
                        .padding(.horizontal, 8)
                    }
                }
            } else {
                VStack {
                    HStack {
                        closeButton
                        Spacer()
                    }

                    ScrollView {
                        VStack(spacing: 24) {
                            summary
                            restartButton
                            incorrectlyAnsweredQuestionsSummary
                        }
                        .frame(maxWidth: 600, minHeight: 400)
                        .padding(.horizontal, 8)
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
    }

    func evaluateSelection(of option: QuizQuestionOption) {
        guard !questionEnded else { return }

        revealedQuestionOptions.insert(option)

        if questionEnded, let currentQuestion = currentQuestion {
            if allCorrectOptionsSelected {
                timeRemainingUntilNextQuestion = 1
                correctlyAnsweredQuestions.append(currentQuestion)
                remainingQuestions.removeFirst()
            } else {
                timeRemainingUntilNextQuestion = 3
                incorrectlyAnsweredQuestions.append(currentQuestion)
                remainingQuestions.removeFirst()
                if incorrectlyAnsweredQuestions.filter({ $0 == currentQuestion }).count < 3 {
                    let newIndex = min(Int.random(in: 5...10), remainingQuestions.count)
                    remainingQuestions.insert(currentQuestion, at: newIndex)
                }
            }
            timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
        }
    }
}
