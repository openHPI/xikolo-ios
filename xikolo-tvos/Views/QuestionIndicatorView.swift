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
    var state: QuestionIndicatorState = .Unanswered
    var correctness: Float?
    var selected = false {
        didSet {
            setNeedsDisplay()
        }
    }

    var delegate: QuestionIndicatorViewDelegate?

    let ringThickness: CGFloat = 6
    let ringColor = UIColor.darkGrayColor()
    let focusedRingColor = UIColor.whiteColor()
    let answeredColor = UIColor.lightGrayColor()

    private var boundsCenter: CGPoint!
    private var radius: CGFloat!
    private var thickness: CGFloat!

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

    override func canBecomeFocused() -> Bool {
        return true
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        setNeedsDisplay()
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        update()
    }

    func update() {
        if let submission = question.submission {
            state = .Answered
            correctness = submission.correctness
        } else {
            state = .Unanswered
        }
        setNeedsDisplay()
    }

    func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.indicatorViewDidSelect(self)
    }

    override func drawRect(rect: CGRect) {
        layer.sublayers = []

        thickness = focused || selected ? ringThickness * 1.5 : ringThickness
        boundsCenter = CGPointMake(bounds.width / 2, bounds.height / 2)
        radius = min(bounds.width, bounds.height) / 2 - (thickness / 2)

        if state == .Answered {
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

    internal func drawCircle(color: UIColor) {
        let path = UIBezierPath()
        path.addArcWithCenter(boundsCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = color.CGColor
        layer.addSublayer(shapeLayer)
    }

    internal func drawCircleSegment(percentage: Double) {
        let angle = CGFloat((percentage * 2 * M_PI) - M_PI_2)

        let path = UIBezierPath()
        path.moveToPoint(boundsCenter)
        path.addArcWithCenter(boundsCenter, radius: radius, startAngle: angle, endAngle: CGFloat(-M_PI_2), clockwise: true)
        path.closePath()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = Brand.IncorrectAnswerColor.CGColor
        layer.addSublayer(shapeLayer)
    }

    internal func drawRing() {
        let path = UIBezierPath()
        path.addArcWithCenter(boundsCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = focused ? focusedRingColor.CGColor : ringColor.CGColor
        shapeLayer.lineWidth = thickness
        layer.addSublayer(shapeLayer)
    }

}

enum QuestionIndicatorState {
    case Answered
    case Unanswered
}

protocol QuestionIndicatorViewDelegate {

    func indicatorViewDidSelect(indicatorView: QuestionIndicatorView)

}
