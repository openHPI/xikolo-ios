//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SwiftUI

@available(iOS 15, *)
struct QuestionOptionView: View {
    let option: QuizQuestionOption

    @Binding var selected: Bool
    @Binding var questionEnded: Bool

    var body: some View {
        Text(option.text ?? "")
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .padding(8)
            .frame(maxWidth: .infinity)
            .foregroundColor(backgroundColor.darker(by: 0.7))
            .background(backgroundColor.lighter(by: 0.2))
            .cornerRadius(18)
    }

    var backgroundColor: Color {
        if selected {
            return option.correct ? Color.green : Color.red
        } else if questionEnded {
            return option.correct ? Color.green : Color(UIColor.systemGray4)
        } else {
            return Color.orange
        }

    }
}

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
