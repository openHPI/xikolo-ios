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
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginFailedLabel: UILabel!
    
    @IBAction func loginButton(sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        UserProfileHelper.login(email, password: password, success: {(success : Bool) -> Void in
            
            if(success) {
                let mainScreen = self.storyboard?.instantiateViewControllerWithIdentifier("CourseOverviewTabBarController")
                self.loginFailedLabel.hidden = true
                self.navigationController?.pushViewController(mainScreen!, animated: true)
            } else {
                self.shake(self.passwordTextField)
                // TODO: maybe check whether email is valid
            }
        
        });
    }
    
    
    @IBAction func registerButton(sender: AnyObject) {
        let url = NSURL(string: Routes.REGISTER_URL)
        UIApplication.sharedApplication().openURL(url!)

    }
    
    var pageIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.placeholder = NSLocalizedString("email", comment: "Email")
        self.passwordTextField.placeholder = NSLocalizedString("password", comment: "Password")
        self.registerButton.setTitle(NSLocalizedString("register", comment: "Register"), forState: UIControlState.Normal)
        
        // Do any additional setup after loading the view.
    }
    
    func shake(viewToAnimate: UIView){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(viewToAnimate.center.x - 2.0, viewToAnimate.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(viewToAnimate.center.x + 2.0, viewToAnimate.center.y))
        viewToAnimate.layer.addAnimation(animation, forKey: "position")
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
