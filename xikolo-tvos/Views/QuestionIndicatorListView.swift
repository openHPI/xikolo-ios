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
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: actualWidth))

        var previousView: UIView?
        for question in questions {
            let view = QuestionIndicatorView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.opaque = false
            indicators[question] = view
            addSubview(view)

            if let previousView = previousView {
                addConstraint(NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: previousView, attribute: .Right, multiplier: 1, constant: margin))
            } else {
                addConstraint(NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0))
            }
            addConstraint(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))

            addConstraint(NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: size))
            addConstraint(NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: size))

            previousView = view
        }
    }

}
