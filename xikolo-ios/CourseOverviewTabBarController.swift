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
        static let ShowLoginSegue = "ShowLoginFromBarButton"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CourseOverviewTabBarController.updateLoginState), name: NotificationKeys.loginSuccessfulKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CourseOverviewTabBarController.updateLogoutState), name: NotificationKeys.logoutSuccessfulKey, object: nil)
        updateBarButton()
        self.navigationItem.hidesBackButton = true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        print("shouldPerformSeguewithidentifier")
        switch identifier {
        case Constants.ShowLoginSegue:
            if isLoggedIn {
                UserProfileHelper.logout() // TODO maybe fade transition
                return false
            } else {
                return true
            }
        default:
            return true
        }
    }
    
    func updateLoginState() {
        isLoggedIn = true
        updateBarButton()
    }
    
    func updateLogoutState() {
        isLoggedIn = false
        updateBarButton()
    }
    
    func updateBarButton() {
        if isLoggedIn {
            dispatch_async(dispatch_get_main_queue(), { 
                self.navigationItem.rightBarButtonItem?.title = ""

            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("login", comment: "Login")
                
            })        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
