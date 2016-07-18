//
//  ReplaceSegue.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 18.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ReplaceSegue : UIStoryboardSegue {

    override func perform() {
        let navigationController = sourceViewController.navigationController!

        var stack = navigationController.viewControllers
        stack[stack.indexOf(sourceViewController)!] = destinationViewController

        navigationController.setViewControllers(stack, animated: false)
    }

}
