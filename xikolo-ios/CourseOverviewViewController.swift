//
//  CourseOverviewViewController.swift
//  xikolo-ios
//
//  Created by Arne Boockmeyer on 08/07/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class CourseOverviewViewController: UICollectionViewController {
    
    private var courses = CourseList()
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private let reuseIdentifier = "CourseCell"
    
    private var flowLayout : UICollectionViewFlowLayout?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.collectionView!.registerNib(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
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
        
        flowLayout = UICollectionViewFlowLayout()
        self.collectionView?.setCollectionViewLayout(flowLayout!, animated: false)
        
        let data = CourseDataProvider.getCourseList()
        data.subscribeNext{
            self.courses = $0
            
            // TODO: Find a better solution
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
        }
    }
    
    @IBAction private func onProfileButtonClick(sender: UIBarButtonItem) -> () {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
extension CourseOverviewViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.courseList.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> CourseCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CourseCell
        
        let course = self.courses.courseList.objectAtIndex(indexPath.row) as! Course
        
        cell.nameLabel.text = course.name
        cell.teacherLabel.text = course.lecturer
        cell.dateLabel.text = course.language
        
        ImageProvider.loadImage(course.visual_url, imageView: cell.backgroundImage)
        
        cell.layer.cornerRadius = 3
        
        return cell
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionView?.performBatchUpdates(nil, completion: nil)
    }
    
}
extension CourseOverviewViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            let width = self.collectionView!.frame.size.width - 20
            
            return CGSize(width: width, height: width * 0.6)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
}