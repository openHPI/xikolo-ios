//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

class RefreshControl: UIRefreshControl {

    typealias Action = () -> Future<Void, XikoloError>
    typealias PostAction = () -> Void

    static let minimumSpinningTime: DispatchTimeInterval = 750.milliseconds

    let action: Action
    let postAction: PostAction

    init(action: @escaping Action, postAction: @escaping PostAction) {
        self.action = action
        self.postAction = postAction
        super.init()
        self.addTarget(self, action: #selector(callAction), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func callAction() {
        let deadline = RefreshControl.minimumSpinningTime.fromNow
        self.action().onSuccess { _ in
            self.postAction()
        }.earliest(at: deadline).onComplete(ImmediateOnMainExecutionContext) { _ in
            self.endRefreshing()
        }
    }

}
