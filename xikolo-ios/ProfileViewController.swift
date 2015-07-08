//
//  ProfileViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coursesLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews();
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
    
    func setupViews() {
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true;
        self.profileImage.layer.borderWidth = 3.0;
        self.profileImage.layer.borderColor = UIColor.whiteColor().CGColor;

    }

}
