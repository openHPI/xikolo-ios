//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

@IBDesignable
class CircularProgressView: UIView {

    @IBInspectable var lineWidth: CGFloat {
        get {
            return self.progressLayer.lineWidth
        }
        set {
            self.progressLayer.lineWidth = newValue
            self.progressLayer.setNeedsDisplay()
        }
    }

    @IBInspectable var gapWidth: CGFloat {
        get {
            return self.progressLayer.gapWidth
        }
        set {
            self.progressLayer.gapWidth = newValue
            self.progressLayer.setNeedsDisplay()
        }
    }

    @IBInspectable var indeterminateProgress: CGFloat = Defaults.indeterminateProgress
    @IBInspectable var indeterminateDuration: Double = Defaults.indeterminateDuration

    var timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

    var progress: CGFloat {
        return self.progressLayer.progress
    }

    private var progressLayer: CircularProgressLayer {
        // swiftlint:disable:next force_cast
        return self.layer as! CircularProgressLayer
    }

    override class var layerClass: AnyClass {
        return CircularProgressLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaults()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if let window = window {
            self.progressLayer.contentsScale = window.screen.scale
            self.progressLayer.setNeedsDisplay()
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.progressLayer.tintColor = self.tintColor
        self.progressLayer.setNeedsDisplay()
    }

    private func setupDefaults() {
        self.progressLayer.tintColor = self.tintColor
        self.progressLayer.lineWidth = Defaults.lineWidth
        self.progressLayer.gapWidth = Defaults.gapWidth
        self.progressLayer.indeterminateProgress = Defaults.indeterminateProgress
        self.indeterminateDuration = Defaults.indeterminateDuration

        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }

    private func pin(_ value: CGFloat, minValue: CGFloat = 0, maxValue: CGFloat = 1) -> CGFloat {
        return min(max(value, minValue), maxValue)
    }

    func updateProgress(_ newValue: Double?, animated: Bool = true) {
        var value: CGFloat?
        if let progress = newValue {
            value = CGFloat(progress)
        }

        self.updateProgress(value, animated: animated)
    }

    func updateProgress(_ newValue: CGFloat?, animated: Bool = true) {
        if let progress = newValue {
            let pinnedProgress = self.pin(progress)
            self.progressLayer.indeterminateProgress = 1
            self.setIndeterminateAnimationState(to: false)

            if animated {
                self.animateProgress(pinnedProgress)
            } else {
                self.progressLayer.progress = pinnedProgress
                self.progressLayer.setNeedsDisplay()
            }
        } else {
            self.progressLayer.indeterminateProgress = self.pin(self.indeterminateProgress, minValue: 0.05, maxValue: 0.9)
            self.setIndeterminateAnimationState(to: true)
            self.progressLayer.progress = 0
            self.progressLayer.setNeedsDisplay()
        }
    }

    private func animateProgress(_ pinnedProgress: CGFloat) {
        self.progressLayer.removeAnimation(forKey: AnimationKeys.progress)

        let currentProgress = self.progressLayer.presentation()?.progress ?? 0
        let duration = CFTimeInterval(fabsf(Float(currentProgress - pinnedProgress)))

        let animation = CABasicAnimation(keyPath: AnimationKeys.progress)
        animation.duration = duration
        animation.timingFunction = self.timingFunction
        animation.fromValue = currentProgress
        animation.toValue = pinnedProgress

        self.progressLayer.progress = pinnedProgress
        self.progressLayer.add(animation, forKey: AnimationKeys.progress)
    }

    private func setIndeterminateAnimationState(to enabled: Bool) {
        if enabled, self.progressLayer.animation(forKey: AnimationKeys.rotation) == nil {
            let animation = CABasicAnimation(keyPath: AnimationKeys.rotation)
            animation.byValue = 2 * CGFloat.pi
            animation.duration = self.indeterminateDuration
            animation.repeatCount = Float.infinity
            animation.isRemovedOnCompletion = false

            self.progressLayer.add(animation, forKey: AnimationKeys.rotation)
        } else if !enabled {
            self.progressLayer.removeAnimation(forKey: AnimationKeys.rotation)
        }
    }

    class CircularProgressLayer: CALayer {

        @NSManaged var tintColor: UIColor
        @NSManaged var lineWidth: CGFloat
        @NSManaged var gapWidth: CGFloat
        @NSManaged var progress: CGFloat
        @NSManaged var indeterminateProgress: CGFloat

        override class func needsDisplay(forKey key: String) -> Bool {
            return key == AnimationKeys.progress ? true : super.needsDisplay(forKey: key)
        }

        override func draw(in ctx: CGContext) {
            let rect = bounds
            let center = CGPoint(x: rect.width / 2, y: rect.height / 2)

            let borderRadius = (min(rect.width, rect.height) - self.lineWidth) / 2
            let borderStartAngle = 1.5 * CGFloat.pi
            let borderEndAngle = borderStartAngle - self.indeterminateProgress * 2 * CGFloat.pi

            ctx.setStrokeColor(self.tintColor.cgColor)
            ctx.setLineWidth(self.lineWidth)
            ctx.setLineCap(.round)
            let borderPath = CGMutablePath()
            borderPath.addArc(center: center, radius: borderRadius, startAngle: borderStartAngle, endAngle: borderEndAngle, clockwise: true)
            ctx.addPath(borderPath)
            ctx.strokePath()

            let bodyRadius = self.gapWidth > 0 ? borderRadius - self.lineWidth / 2 - self.gapWidth : borderRadius
            let bodyEndAngle = 1.5 * CGFloat.pi
            let bodyStartAngle = bodyEndAngle + self.progress * 2 * CGFloat.pi

            ctx.setFillColor(self.tintColor.cgColor)
            let bodyPath = CGMutablePath()
            bodyPath.move(to: center)
            bodyPath.addArc(center: center, radius: bodyRadius, startAngle: bodyStartAngle, endAngle: bodyEndAngle, clockwise: true)
            bodyPath.closeSubpath()
            ctx.addPath(bodyPath)
            ctx.fillPath()
        }

    }

    enum Defaults {
        static let progress: CGFloat = 0
        static let lineWidth: CGFloat = 2.0
        static let gapWidth: CGFloat = 0
        static let indeterminateDuration: CFTimeInterval = 1.0
        static let indeterminateProgress: CGFloat = 0.8
    }

    enum AnimationKeys {
        static let progress = "progress"
        static let rotation = "transform.rotation"
    }

}
