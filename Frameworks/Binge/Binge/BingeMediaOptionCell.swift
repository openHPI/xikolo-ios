//
//  BingeMediaOptionCell.swift
//  Binge
//
//  Created by Max Bothe on 21.01.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import UIKit

class BingeMediaOptionCell: UITableViewCell {

    static let identifier = "BingeMediaOptionCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.textLabel?.textColor = .white
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.textLabel?.adjustsFontForContentSizeCategory = true
        self.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        self.tintColor = .white
        self.selectionStyle = .none

    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            self.accessoryType = self.isSelected ? .checkmark : .none
            let pointSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let weight: UIFont.Weight = self.isSelected ? .bold : .regular
            self.textLabel?.font = UIFont.systemFont(ofSize: pointSize, weight: weight)
        }
    }

}
