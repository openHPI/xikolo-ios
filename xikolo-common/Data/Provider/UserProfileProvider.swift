//
//  UserProfileProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 20.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import BrightFutures
import Foundation

class UserProfileProvider {

    static func getMyProfile() -> Future<UserProfile, XikoloError> {
        let promise = Promise<UserProfile, XikoloError>()

        let url = Routes.MY_PROFILE_API_URL
        Alamofire.request(.GET, url, headers: NetworkHelper.getRequestHeaders()).responseObject() { (response: Response<UserProfile, NSError>) in
            if let user = response.result.value {
                promise.success(user)
                return
            }
            if let error = response.result.error {
                promise.failure(XikoloError.Network(error))
                return
            }
            promise.failure(XikoloError.TotallyUnknownError)
        }
        return promise.future
    }

}
