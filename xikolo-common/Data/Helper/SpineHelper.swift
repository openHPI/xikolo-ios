//
//  SpineHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 12.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class SpineHelper {

    fileprivate static var client: Spine = {
        #if DEBUG
            Spine.setLogLevel(.debug, forDomain: .networking)
            Spine.setLogLevel(.debug, forDomain: .serializing)
            Spine.setLogLevel(.debug, forDomain: .spine)
        #endif

        let spine = Spine(baseURL: URL(string: Routes.API_V2_URL)!)
        SpineHelper.updateHttpHeaders(spine)

        spine.registerValueFormatter(EmbeddedObjectFormatter())
        spine.registerValueFormatter(EmbeddedObjectsFormatter())
        spine.registerValueFormatter(EmbeddedDictFormatter())
        spine.registerValueFormatter(VideoStreamFormatter())

        spine.registerResource(ChannelSpine.self)
        spine.registerResource(CourseSpine.self)
        spine.registerResource(EnrollmentSpine.self)
        spine.registerResource(CourseItemSpine.self)
        spine.registerResource(CourseSectionSpine.self)
        spine.registerResource(CourseDateSpine.self)
        spine.registerResource(ContentSpine.self)
        spine.registerResource(LTIExerciseSpine.self)
        spine.registerResource(PeerAssessmentSpine.self)
        spine.registerResource(PlatformEventSpine.self)
        spine.registerResource(QuizSpine.self)
        spine.registerResource(QuizQuestionSpine.self)
        spine.registerResource(QuizSubmission.self)
        spine.registerResource(RichTextSpine.self)
        spine.registerResource(VideoSpine.self)
        spine.registerResource(AnnouncementSpine.self)
        spine.registerResource(TrackingEvent.self)
        spine.registerResource(UserSpine.self)
        spine.registerResource(UserProfileSpine.self)

        let nsCenter = NotificationCenter.default
        nsCenter.addObserver(SpineHelper.self, selector: #selector(SpineHelper.updateAfterLoginLogout), name: NotificationKeys.loginSuccessfulKey, object: nil)
        nsCenter.addObserver(SpineHelper.self, selector: #selector(SpineHelper.updateAfterLoginLogout), name: NotificationKeys.logoutSuccessfulKey, object: nil)

        return spine
    }()

    @objc fileprivate static func updateAfterLoginLogout() {
        updateHttpHeaders(client)
    }

    fileprivate static func updateHttpHeaders(_ spine: Spine) {
        let httpClient = spine.networkClient as! HTTPClient
        NetworkHelper.getRequestHeaders().forEach { key, value in
            httpClient.setHeader(key, to: value)
        }
    }

    static func findAll<T: Resource>(_ type: T.Type) -> Future<[T], XikoloError> {
        return client.findAll(type).map { resources, _, _ in
            return resources.map { $0 as! T }
        }.mapError(mapXikoloError)
    }

    static func find<T: Resource>(_ query: Query<T>) -> Future<[T], XikoloError> {
        return client.find(query).map { resources, _, _ in
            return resources.map { $0 as! T }
        }.mapError(mapXikoloError)
    }

    static func findOne<T: Resource>(_ id: String, ofType type: T.Type) -> Future<T, XikoloError> {
        return client.findOne(id, ofType: type).map { resource, _, _ in
            return resource
        }.mapError(mapXikoloError)
    }

    static func findOne<T: Resource>(_ query: Query<T>) -> Future<T, XikoloError> {
        return client.findOne(query).map { resource, _, _ in
            return resource
        }.mapError(mapXikoloError)
    }

    static func save<T: Resource>(_ resource: T) -> Future<T, XikoloError> {
        return client.save(resource).mapError(mapXikoloError)
    }

    static func delete<T: Resource>(_ resource: T) -> Future<Void, XikoloError> {
        return client.delete(resource).mapError(mapXikoloError)
    }

    fileprivate static func mapXikoloError(_ error: SpineError) -> XikoloError {
        return XikoloError.api(error)
    }

}
