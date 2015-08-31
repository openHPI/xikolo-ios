//
//  LoginCheckController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 17.08.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class LoginCheckController: UIViewController {


    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if logged in
        let nextViewController : UIViewController!
        
        if(UserProfile.isLoggedIn()) {
            nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CourseOverviewViewController")
            self.navigationController?.pushViewController(nextViewController, animated: false)
        }
        
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
