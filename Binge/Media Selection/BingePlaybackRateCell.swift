//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class BingePlaybackRateCell: UITableViewCell {

    static let identifier = "BingePlaybackRateCell"

    private lazy var stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.setDecrementImage(stepper.decrementImage(for: .normal), for: .normal)
        stepper.setIncrementImage(stepper.incrementImage(for: .normal), for: .normal)

        stepper.stepValue = 0.25
        stepper.minimumValue = 0.75
        stepper.maximumValue = 2.0
        stepper.value = 1.0
        stepper.addTarget(self, action: #selector(rateChanged), for: .valueChanged)
        return stepper
    }()

    weak var delegate: BingePlaybackRateDelegate? {
        didSet {
            guard let rate = self.delegate?.currentRate else { return }
            self.textLabel?.text = self.formatStepValue(Double(rate))
            self.stepper.value = Double(rate)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.textLabel?.textColor = .white
        self.textLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        self.textLabel?.adjustsFontForContentSizeCategory = true
        self.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        self.tintColor = .white
        self.selectionStyle = .none
        self.accessoryView = self.stepper
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func rateChanged() {
        let stepValues = stride(from: self.stepper.minimumValue, through: self.stepper.maximumValue, by: self.stepper.stepValue)
        let stepDifferences = stepValues.map { ($0, abs($0 - self.stepper.value)) }
        let sortedStepDifferences = stepDifferences.sorted { $0.1 < $1.1 }
        let newRate = sortedStepDifferences.first?.0 ?? self.stepper.value
        self.stepper.value = newRate
        self.textLabel?.text = self.formatStepValue(newRate)
        self.delegate?.changeRate(to: Float(newRate))
    }

    private func formatStepValue(_ value: Double) -> String {
        return String(format: "%.2fx", value)
    }

}
