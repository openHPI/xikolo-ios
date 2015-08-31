//
//  ImageProvider.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.08.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class ImageProvider: NSObject {
    
    static func loadImage(visual_url : String, imageView : UIImageView) {
        
        // TODO:
        // Return standard placeholder image
        // Return course image as soon as it is finished
        // Handle Exceptions
        
//        let imageSubscripton = just(visual_url)
//            . throttle(0.2, MainScheduler.sharedInstance)
//            . flatMap { imageURL in
//                //                API.fetchImage(imageURL)
//            }
//            . observeOn(MainScheduler.sharedInstance)
//            . subscribeNext { image in
//                imageView.image = image
//        }
        
        if(!visual_url.isEmpty ?? false) {
            let url = NSURL(string: visual_url)!
            let request = NSURLRequest(URL: url)
            
            NSURLSession.sharedSession().rx_data(request)
                .map { data in
                    UIImage(data: data)
                }
                .observeSingleOn(MainScheduler.sharedInstance)
                .subscribeImageOf(imageView)
            //            .addDisposableTo(disposeBag)
        }
        
    }
    
    static func fetchImage(visual_url : String) -> UIImage {
        if let url = NSURL(string: visual_url) {
            if let data = NSData(contentsOfURL: url){
                return UIImage(data: data, scale: 1.0)!
            }
        }
        
        // TODO: Change to standard placeholder image
        return UIImage()
    }
    
}
