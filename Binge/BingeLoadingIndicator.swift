//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class BingeLoadingIndicator: UIView {

    @IBInspectable var lineWidth: CGFloat {
        get {
            return self.loadingIndicatorLayer.lineWidth
        }
        set {
            self.loadingIndicatorLayer.lineWidth = newValue
            self.loadingIndicatorLayer.setNeedsDisplay()
        }
    }

    @IBInspectable var gap: CGFloat {
        get {
            return self.loadingIndicatorLayer.gap
        }
        set {
            self.loadingIndicatorLayer.gap = newValue
            self.loadingIndicatorLayer.setNeedsDisplay()
        }
    }

    @IBInspectable var duration: CFTimeInterval = 1.0

    private var loadingIndicatorLayer: BingeLoadingIndicatorLayer {
        return self.layer as! BingeLoadingIndicatorLayer // swiftlint:disable:this force_cast
    }

    override static var layerClass: AnyClass {
        return BingeLoadingIndicatorLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupDefaults()
        self.startAnimation()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupDefaults()
        self.startAnimation()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if let window = window {
            self.loadingIndicatorLayer.contentsScale = window.screen.scale
            self.loadingIndicatorLayer.setNeedsDisplay()
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.loadingIndicatorLayer.tintColor = self.tintColor
        self.loadingIndicatorLayer.setNeedsDisplay()
    }

    private func setupDefaults() {
        self.loadingIndicatorLayer.tintColor = self.tintColor
        self.loadingIndicatorLayer.lineWidth = 2
        self.loadingIndicatorLayer.gap = 0.2
        self.duration = 1.0

        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }

    private func startAnimation() {
        let animationKeyPath = "transform.rotation"
        let animation = CABasicAnimation(keyPath: animationKeyPath)
        animation.byValue = 2 * CGFloat.pi
        animation.duration = self.duration
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        self.loadingIndicatorLayer.add(animation, forKey: animationKeyPath)
    }

    class BingeLoadingIndicatorLayer: CALayer {

        @NSManaged var tintColor: UIColor
        @NSManaged var lineWidth: CGFloat
        @NSManaged var gap: CGFloat

        override func draw(in ctx: CGContext) {
            let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)

            let borderRadius = (min(self.bounds.width, self.bounds.height) - self.lineWidth) / 2
            let borderStartAngle = 1.5 * CGFloat.pi
            let borderEndAngle = borderStartAngle - self.gap * 2 * CGFloat.pi

            ctx.setStrokeColor(self.tintColor.cgColor)
            ctx.setLineWidth(self.lineWidth)
            ctx.setLineCap(.round)
            let borderPath = CGMutablePath()
            borderPath.addArc(center: center, radius: borderRadius, startAngle: borderStartAngle, endAngle: borderEndAngle, clockwise: false)
            ctx.addPath(borderPath)
            ctx.strokePath()
        }

    }

}
