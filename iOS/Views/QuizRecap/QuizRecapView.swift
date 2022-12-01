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

    var recapEnded: Bool { remainingQuestions.isEmpty }

    @State var currentQuestion: QuizQuestion? {
        didSet {
            allOptions = {
                guard let question = currentQuestion else { return [] }
                return question.shuffleOptions ? question.options.shuffled() : question.options
            }()
            revealedQuestionOptions = []
            timeRemainingUntilNextQuestion = 3
        }
    }
    @State var revealedQuestionOptions: Set<QuizQuestionOption> = []
    @State var allOptions: [QuizQuestionOption] = []

    var allCorrectOptions: Set<QuizQuestionOption> {
        Set(currentQuestion?.options.filter(\.correct) ?? [])
    }

    var allCorrectOptionsSelected: Bool {
        allCorrectOptions == revealedQuestionOptions
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
            Text(question.text ?? "")
                .font(.body)
                .fontWeight(.medium)
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

    var summary: some View {
        VStack {
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

            VStack(spacing: 16) {
                Text("Quiz abgeschlossen!")
                    .font(.headline)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                Text("Glückwunsch, Sie haben \(successCount) Fragen in insgesamt \(successCount + errorCount) Versuchen beantwortet.") // TODO: Plural
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

                Text("Großartig, Sie haben alle Fragen richtig beantwortet. Versuchen Sie es erneut mit mehr Fragen.")
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
            }
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(16)
        }
    }

    var body: some View {
        Group {
            if let currentQuestion = currentQuestion, !recapEnded {
                VStack {
                    HStack {
                        Button {
                            remainingQuestions = []
                        } label: {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop")
                            }
                            .font(.footnote)
                            .foregroundColor(.primary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(999)
                        }
                        .padding()
                        Spacer()
                        topInfo
                    }
                    ScrollView {
                        VStack {
                            VStack(spacing: 24) {
                                questionEndView
                                questionDescription(for: currentQuestion)
                                questionOptions

                                Text("Next question in \( timeRemainingUntilNextQuestion + 1)...")
                                    .font(.callout.monospacedDigit())
                                    .foregroundColor(.secondary)
                                    .opacity(questionEnded && timeRemainingUntilNextQuestion < 3 ? 1 : 0)

                            }
                            .padding(.horizontal, 8)
//                            .frame(maxWidth: 400, minHeight: 400) // TOOD: check values
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                VStack {
                    HStack {
                        Button {
                            dismissAction()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.primary, Color(UIColor.secondarySystemBackground))
                                .foregroundColor(.secondary)
                                .font(.system(size: 24))
                        }
                        .padding()
                        Spacer()
                    }
                    ScrollView {
                        VStack(spacing: 24) {
                            summary
                            Button {
                                loadNewQuestionSet()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Restart with xx new questions")
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

                            if 1 != 0 {
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
                        .padding(.horizontal)
//                        .frame(maxWidth: 400, minHeight: 400) // TODO: check values
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
                timeRemainingUntilNextQuestion = 2
                correctlyAnsweredQuestions.append(currentQuestion)
                remainingQuestions.removeFirst()
            } else {
                timeRemainingUntilNextQuestion = 4
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

@available(iOS 15, *)
struct QuizRecapView_Previews: PreviewProvider {
    static var previews: some View {
//        QuizRecapView()
        Text("Test")
    }
}
