//
//  ProfileDataProvider.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.08.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import SwiftyJSON
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class ProfileDataProvider: MultiSourceProvider {
    
    typealias T = UserProfile
    
    static let urlSession = NSURLSession.sharedSession()
    
    static func getObservable() -> Observable<UserProfile> {
        
        let local = getLocalDataObservable()
        let network = getNetworkDataObservable()
        
        // Concat emits the emissions from two or more Observables without interleaving them
        // take(1) ensures that only one datastream is used, so if there is no local data
        // it will do a network request but if there is local data the network request will happen
        let combinedObservable = concat([local, network])
        
        return combinedObservable
    }
    
    static internal func getLocalDataObservable() -> Observable<UserProfile> {
        let user = UserProfileHelper.getSavedUser()
        return just(user)
    }
    
    static internal func getNetworkDataObservable() -> Observable<UserProfile> {
        
        let urlString = Routes.API_URL + Routes.MY_PROFILE
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var user = UserProfile()
        
        request.addValue(Routes.HTTP_ACCEPT_HEADER_VALUE, forHTTPHeaderField: Routes.HTTP_ACCEPT_HEADER)
        request.addValue("Token token=\"" + UserProfileHelper.getToken() + "\"", forHTTPHeaderField: Routes.HTTP_AUTH_HEADER)
        
        print("Starting profile request")
        
        return self.urlSession.rx_response(request).map{(maybeData, maybeResponse) in
            
            if let response = maybeResponse as? NSHTTPURLResponse {
                // TODO:
                // Check Response Status (shoulde be 200?)
                // Parse JSON Data
                // Fill Course List
                
                let json = JSON(data: maybeData)
                user = UserProfile(json: json)
                
            }
            
            // TODO Handle if no data
            
            print("Profile request finished")
            
            UserProfileHelper.update(user)
            return user
            
        }
    }
}