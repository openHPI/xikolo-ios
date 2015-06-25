//
//  PageContentViewController.swift
//  xikolo-ios
//
//  Created by Jan Renz on 25/06/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation
import UIKit

class PageContentViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var pageIndex: Int?
    var titleText: String?
    var imageName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(named: imageName)
        self.label.alpha = 0.1
        self.label.text = self.titleText
        
        UIView.animateWithDuration(1.0, animations: {
            self.label.alpha = 1.0
        })

    }
    

}
