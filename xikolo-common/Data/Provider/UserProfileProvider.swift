//
//  UserProfileProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 20.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import Foundation

class UserProfileProvider {

    static func getMyProfile(completionHandler: (user: UserProfile?, error: NSError?) -> ()) {
        let url = Routes.MY_PROFILE_API_URL

        Alamofire.request(.GET, url, headers: NetworkHelper.getRequestHeaders()).responseObject() { (response: Response<UserProfile, NSError>) in
            if let user = response.result.value {
                completionHandler(user: user, error: nil)
                return
            }
            completionHandler(user: nil, error: response.result.error)
        }
    }

}
