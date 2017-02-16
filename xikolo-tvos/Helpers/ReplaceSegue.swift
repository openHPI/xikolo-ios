//
//  ReplaceSegue.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 18.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ReplaceSegue : UIStoryboardSegue {

    var animated = true

    override func perform() {
        // If the sourceViewController was dismissed before the segue completes, don't continue with the segue.
        if let navigationController = source.navigationController {
            var stack = navigationController.viewControllers
            stack[stack.index(of: source)!] = destination

            navigationController.setViewControllers(stack, animated: animated)
        }
    }

}
