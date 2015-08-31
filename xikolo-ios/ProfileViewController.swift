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
    @IBOutlet weak var coursesCountLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews();
        setViewData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true;
        self.profileImage.layer.borderWidth = 3.0;
        self.profileImage.layer.borderColor = UIColor.whiteColor().CGColor;

    }
    
    func setViewData() {
//        let user = UserModel.getSavedUser()
//        
//        self.emailLabel.text = user.email;
//        self.nameLabel.text = user.firstName + " " + user.lastName;
//        
//        setAvatar(user);
//        setCourses();
        
        let userProfileObservable = ProfileDataProvider.getObservable()
        userProfileObservable.subscribeNext { userProfile in
            self.nameLabel.text = userProfile.firstName + " " + userProfile.lastName
            self.emailLabel.text = userProfile.email
            
            ImageProvider.loadImage(userProfile.visual, imageView: self.profileImage)
        }
        
    }
    
//    func setAvatar(user : User) {
//        // TODO Database / API call
//    }
//    
//    func setCourses() {
//        // TODO Set course enrollments count
//    }

}
