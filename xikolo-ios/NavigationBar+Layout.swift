//
//  NavigationBar+Layout.swift
//  xikolo-ios
//
//  Created by Max Bothe on 28.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit

//class BorderedXikoloNavigationController : UINavigationController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationBar.barTintColor = UIColor.white
//        self.navigationBar.isTranslucent = true
//    }
//
//}

class XikoloNavigationController : UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.isTranslucent = true
        self.navigationBar.shadowImage = UIImage()
    }

}
