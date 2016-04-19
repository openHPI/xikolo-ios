        //
//  CourseOverviewTabBarController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 01.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class CourseOverviewTabBarController: UITabBarController {
    
    var isLoggedIn = UserProfileHelper.isLoggedIn()
    
    private struct Constants{
        static let ShowLoginSegue = "Show Login"
        static let ShowProfileSegue = "Show Profile"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
