//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

protocol BingePlaybackRateDelegate: AnyObject {

    var currentRate: Float { get }

    func changeRate(to rate: Float)

}
