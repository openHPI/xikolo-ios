//
//  AbstractCourseListViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif
import UIKit

class AbstractCourseListViewController : UICollectionViewController {

    enum CourseDisplayMode {
        case EnrolledOnly
        case All
    }
    
    var courseDisplayMode: CourseDisplayMode = .All
    
    var courses: CourseList = CourseList()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        let data : Observable<CourseList>
        
        switch courseDisplayMode {
            case .EnrolledOnly:
                data = CourseDataProvider.getMyCourses()
            case .All:
                data = CourseDataProvider.getCourseList()
        }

        data.subscribeNext {
            self.courses = $0

            // TODO: Find a better solution
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
        }
    }

}
