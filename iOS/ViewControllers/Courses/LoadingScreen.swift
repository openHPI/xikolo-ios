//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Common
import UIKit

public class LoadingScreen: UIViewController {

    @IBOutlet weak var progressView: CircularProgressView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        let progressValue: CGFloat? = nil
        progressView.updateProgress(progressValue)
    }

}
