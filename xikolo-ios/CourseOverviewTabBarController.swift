//
//  CourseOverviewTabBarController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 01.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class CourseOverviewTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        // Profile View
        let profileButton = UIButton(type: UIButtonType.Custom)
        let image = UIImage(named: "Avatar")
        profileButton.setImage(image, forState: UIControlState.Normal)
        profileButton.frame.size = CGSize(width: 35, height: 35)
        profileButton.layer.masksToBounds = false
        // TODO:
        // Make circle shaped view
        profileButton.layer.cornerRadius = 8.0
        profileButton.addTarget(self, action: "onProfileButtonClick:", forControlEvents: UIControlEvents.TouchDown)
        let barButton = UIBarButtonItem(customView: profileButton)
        self.navigationItem.rightBarButtonItem = barButton

        let storyboard = self.storyboard
        
        let allCourses = storyboard!.instantiateViewControllerWithIdentifier("CourseOverviewViewController")
        let myCourses = storyboard!.instantiateViewControllerWithIdentifier("CourseOverviewViewController")
        let news = storyboard!.instantiateViewControllerWithIdentifier("NewsViewController")
        let settings = storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController")
        
        let viewControllers = [allCourses, myCourses, news, settings]
        
        self.setViewControllers(viewControllers, animated: false)
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSFontAttributeName:UIFont(name: "openHPI4", size: 25)!]
        appearance.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        
        let titleAllCourses = Icons.learn2 + "\n" + "All Courses"
        let titleMyCourses = Icons.subscribe + "\n" + "My Courses"
        let titleNews = Icons.announcements + "\n" + "News"
        let titleSettings = Icons.settings + "\n" + "Settings"
        
        allCourses.tabBarItem = UITabBarItem(title: titleAllCourses, image: nil, tag: 0)
        myCourses.tabBarItem = UITabBarItem(title: titleMyCourses, image: nil, tag: 1)
        news.tabBarItem = UITabBarItem(title: titleNews, image: nil, tag: 2)
        settings.tabBarItem = UITabBarItem(title: titleSettings, image: nil, tag: 3)
        
        allCourses.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0,vertical: -15)
        myCourses.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0,vertical: -15)
        news.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0,vertical: -15)
        settings.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0,vertical: -15)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction private func onProfileButtonClick(sender: UIBarButtonItem) -> () {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
