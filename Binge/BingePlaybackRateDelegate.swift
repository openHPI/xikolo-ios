//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

protocol BingePlaybackRateDelegate: AnyObject {
    var currentRate: Float { get }
    func changeRate(to: Float)
}
