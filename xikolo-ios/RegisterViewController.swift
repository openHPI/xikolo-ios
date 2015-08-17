//
//  RegisterViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.06.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButton(sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        UserModel.login(email, password: password, success: {(success : Bool) -> Void in
            
            if(success) {
                // TODO Segue to Main Screen
                let mainScreen = self.storyboard?.instantiateViewControllerWithIdentifier("CourseOverviewViewController")
                self.navigationController?.pushViewController(mainScreen!, animated: true)
            } else {
                // TODO Notify user about failed login
            }
        
        });
    }
    
    @IBAction func registerButton(sender: AnyObject) {
        let url = NSURL(string: "https://open.hpi.de/account/new")
        UIApplication.sharedApplication().openURL(url!)

    }
    
    var pageIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
