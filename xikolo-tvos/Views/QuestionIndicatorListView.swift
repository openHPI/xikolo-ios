//
//  QuestionIndicatorListView.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 16.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class QuestionIndicatorListView : UIView {

    var questions: [QuizQuestion]! {
        didSet {
            configure()
        }
    }

    var activeQuestion: QuizQuestion! {
        didSet {
            if oldValue != nil {
                indicators[oldValue]?.selected = false
            }
            indicators[activeQuestion]?.selected = true
        }
    }

    var indicators = [QuizQuestion: QuestionIndicatorView]()

    func configure() {
        let margin: CGFloat = 20
        let maxWidth: CGFloat = 1920 - 90 - 90
        let maxSize = bounds.height

        let margins = CGFloat(questions.count - 1) * margin
        var size = (maxWidth - margins) / CGFloat(questions.count)
        if size > maxSize {
            size = maxSize
        }

        let actualWidth = CGFloat(questions.count) * size + margins
        self.widthAnchor.constraintEqualToConstant(actualWidth).active = true

        var previousView: UIView?
        for question in questions {
            let view = QuestionIndicatorView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.opaque = false
            indicators[question] = view
            addSubview(view)

            if let previousView = previousView {
                view.leftAnchor.constraintEqualToAnchor(previousView.rightAnchor, constant: margin).active = true
            } else {
                view.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
            }
            view.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true

            view.widthAnchor.constraintEqualToConstant(size).active = true
            view.heightAnchor.constraintEqualToConstant(size).active = true

            previousView = view
        }
    }

}
