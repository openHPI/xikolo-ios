//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation
import UIKit

public class LoadingScreen: UIViewController {

    @IBOutlet private weak var progressView: CircularProgressView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.0

        UIView.animate(withDuration: 0.25, delay: 1.25, options: .curveEaseIn) {
            self.view.alpha = 1.0
        }

        let progressValue: CGFloat? = nil
        progressView.updateProgress(progressValue)
    }

}
