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

    var delegate: QuestionIndicatorListViewDelegate?

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
        self.widthAnchor.constraint(equalToConstant: actualWidth).isActive = true

        var previousView: UIView?
        for question in questions {
            let view = QuestionIndicatorView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isOpaque = false
            view.delegate = self
            indicators[question] = view
            view.question = question
            addSubview(view)

            if let previousView = previousView {
                view.leftAnchor.constraint(equalTo: previousView.rightAnchor, constant: margin).isActive = true
            } else {
                view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            }
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

            view.widthAnchor.constraint(equalToConstant: size).isActive = true
            view.heightAnchor.constraint(equalToConstant: size).isActive = true

            previousView = view
        }
    }

    func updateAll() {
        for (_, indicator) in indicators {
            indicator.update()
        }
    }

}

extension QuestionIndicatorListView : QuestionIndicatorViewDelegate {

    func indicatorViewDidSelect(_ indicatorView: QuestionIndicatorView) {
        let question = indicatorView.question!
        let index = questions.index(of: question)!
        delegate?.indicatorListView(self, didSelectQuestionWithIndex: index)
    }

}

protocol QuestionIndicatorListViewDelegate {

    func indicatorListView(_ indicatorListView: QuestionIndicatorListView, didSelectQuestionWithIndex index: Int)

}
