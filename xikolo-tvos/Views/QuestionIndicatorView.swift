//
//  QuestionIndicator.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 15.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class QuestionIndicatorView : UIView {

    var question: QuizQuestion!
    var state: QuestionIndicatorState = .Unanswered
    var correctness: Float?
    var selected = false {
        didSet {
            setNeedsDisplay()
        }
    }

    let ringThickness: CGFloat = 6
    let ringColor = UIColor.darkGrayColor()
    let answeredColor = UIColor.grayColor()
    let correctColor = UIColor.greenColor()
    let incorrectColor = UIColor.redColor()

    private var boundsCenter: CGPoint!
    private var radius: CGFloat!
    private var thickness: CGFloat!

    func update() {
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        layer.sublayers = []

        thickness = selected ? ringThickness * 1.5 : ringThickness
        boundsCenter = CGPointMake(bounds.width / 2, bounds.height / 2)
        radius = min(bounds.width, bounds.height) / 2 - (thickness / 2)

        if state == .Answered {
            if let correctness = correctness {
                if correctness == 0 {
                    drawCircle(incorrectColor)
                } else {
                    drawCircle(correctColor)
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
        shapeLayer.fillColor = UIColor.redColor().CGColor
        layer.addSublayer(shapeLayer)
    }

    internal func drawRing() {
        let path = UIBezierPath()
        path.addArcWithCenter(boundsCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = ringColor.CGColor
        shapeLayer.lineWidth = thickness
        layer.addSublayer(shapeLayer)
    }

}

enum QuestionIndicatorState {
    case Answered
    case Unanswered
}
