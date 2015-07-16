//
//  MainNavigationController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 09.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.topItem!.title = "openHPI";
        self.navigationBar.barTintColor = UIColor(red: 222/255, green: 98/255, blue: 18/255, alpha: 1)
        self.navigationBar.tintColor = UIColor(red: 180/255, green: 41/255, blue: 70/255, alpha: 1);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
