//
//  QuestionIndicator.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 15.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class QuestionIndicatorView : UIView {

    var question: QuizQuestion! {
        didSet {
            question.addObserver(self, forKeyPath: "submission", options: NSKeyValueObservingOptions(), context: nil)
        }
    }
    var state: QuestionIndicatorState = .unanswered
    var correctness: Float?
    var selected = false {
        didSet {
            setNeedsDisplay()
        }
    }

    var delegate: QuestionIndicatorViewDelegate?

    let ringThickness: CGFloat = 6
    let ringColor = UIColor.darkGray
    let focusedRingColor = UIColor.white
    let answeredColor = UIColor.lightGray

    fileprivate var boundsCenter: CGPoint!
    fileprivate var radius: CGFloat!
    fileprivate var thickness: CGFloat!

    required override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    deinit {
        question.removeObserver(self, forKeyPath: "submission")
    }

    func initialize() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapRecognizer)
    }

    override var canBecomeFocused : Bool {
        return true
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        setNeedsDisplay()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        update()
    }

    func update() {
        if let submission = question.submission {
            state = .answered
            correctness = submission.correctness
        } else {
            state = .unanswered
        }
        setNeedsDisplay()
    }

    func handleTap(_ recognizer: UITapGestureRecognizer) {
        delegate?.indicatorViewDidSelect(self)
    }

    override func draw(_ rect: CGRect) {
        layer.sublayers = []

        thickness = isFocused || selected ? ringThickness * 1.5 : ringThickness
        boundsCenter = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        radius = min(bounds.width, bounds.height) / 2 - (thickness / 2)

        if state == .answered {
            if let correctness = correctness {
                if correctness == 0 {
                    drawCircle(Brand.IncorrectAnswerColor)
                } else {
                    drawCircle(Brand.CorrectAnswerColor)
                    if correctness < 1 {
                        drawCircleSegment(Double(correctness))
                    }
                }
            } else {
                drawCircle(answeredColor)
            }
        }

        drawRing()
    }

    internal func drawCircle(_ color: UIColor) {
        let path = UIBezierPath()
        path.addArc(withCenter: boundsCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor
        layer.addSublayer(shapeLayer)
    }

    internal func drawCircleSegment(_ percentage: Double) {
        let angle = CGFloat((percentage * 2 * M_PI) - M_PI_2)

        let path = UIBezierPath()
        path.move(to: boundsCenter)
        path.addArc(withCenter: boundsCenter, radius: radius, startAngle: angle, endAngle: CGFloat(-M_PI_2), clockwise: true)
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = Brand.IncorrectAnswerColor.cgColor
        layer.addSublayer(shapeLayer)
    }

    internal func drawRing() {
        let path = UIBezierPath()
        path.addArc(withCenter: boundsCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = isFocused ? focusedRingColor.cgColor : ringColor.cgColor
        shapeLayer.lineWidth = thickness
        layer.addSublayer(shapeLayer)
    }

}

enum QuestionIndicatorState {
    case answered
    case unanswered
}

protocol QuestionIndicatorViewDelegate {

    func indicatorViewDidSelect(_ indicatorView: QuestionIndicatorView)

}
