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
        Alamofire.request(url, method: .get, headers: NetworkHelper.getRequestHeaders()).responseObject() { (response: DataResponse<UserProfile>) in
            if let user = response.result.value {
                return promise.success(user)
            }
            if let error = response.result.error {
                return promise.failure(XikoloError.network(error))
            }
            return promise.failure(XikoloError.totallyUnknownError)
        }
        return promise.future
    }

}
