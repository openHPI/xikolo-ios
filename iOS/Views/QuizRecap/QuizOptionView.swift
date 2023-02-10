//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SwiftUI

@available(iOS 15, *)
struct QuestionOptionView: View {

    @Environment(\.colorScheme) var colorScheme

    let option: QuizQuestionOption

    @Binding var selected: Bool
    @Binding var questionEnded: Bool

    var attributedFallbackQuestionText: String? {
        guard let text = option.text else { return nil }
        let textFromAttributedString = MarkdownHelper.string(for: text)
        return textFromAttributedString.isEmpty ? nil : textFromAttributedString
    }

    var body: some View {
        Group {
            if let attributedFallbackQuestionText = attributedFallbackQuestionText, attributedFallbackQuestionText != option.text {
                Text(attributedFallbackQuestionText)
            } else {
                Text(option.text ?? "")
                    .multilineTextAlignment(.center)
            }
        }
        .lineLimit(nil)
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 66)
        .foregroundColor(
            colorScheme == .dark ? backgroundColor.lighter(by: 0.9) : backgroundColor.darker(by: 0.9)
        )
        .background(
            colorScheme == .dark ? backgroundColor.darker(by: 0.5) : backgroundColor.lighter(by: 0.2)
        )
        .cornerRadius(22)
    }

    var backgroundColor: Color {
        if selected {
            return option.correct ? Color.green : Color.red
        } else if questionEnded {
            return option.correct ? Color.green : Color(UIColor.systemGray4)
        } else {
            return colorScheme == .dark ? Color(Brand.default.colors.primary) : Color(Brand.default.colors.primaryLight)
        }
    }

}

#if DEBUG
@available(iOS 15, *)
struct QuestionOptionView_Previews: PreviewProvider {
    static let correctOption = {
        return try! QuizQuestionOption(object: [
            "id": UUID().uuidString,
            "text": "correct",
            "position": 0,
            "correct": true,
            "explanation": "foobar",
        ])
    }()

    static let incorrectOption = {
        return try! QuizQuestionOption(object: [
            "id": UUID().uuidString,
            "text": "incorrect",
            "position": 0,
            "correct": false,
            "explanation": "foobar",
        ])
    }()

    static var previews: some View {
        ForEach([correctOption, incorrectOption], id: \.id) { option in
            QuestionOptionView(option: option, selected: .constant(false), questionEnded: .constant(false))
        }
    }
}
#endif
