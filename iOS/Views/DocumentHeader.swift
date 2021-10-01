//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class DocumentHeader: UITableViewHeaderFooterView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var tagsLabel: UILabel!

    func configure(for document: Document) {
        self.titleLabel.text = document.title
        self.descriptionLabel.text = document.documentDescription?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.descriptionLabel.textColor = ColorCompatibility.secondaryLabel
        self.tagsLabel.text = document.tags.isEmpty ? nil : document.tags.joined(separator: " · ")
    }

}
