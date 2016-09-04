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

    private static var client: Spine = {
        #if DEBUG
            Spine.setLogLevel(.Debug, forDomain: .Networking)
            Spine.setLogLevel(.Debug, forDomain: .Serializing)
            Spine.setLogLevel(.Debug, forDomain: .Spine)
        #endif

        let spine = Spine(baseURL: NSURL(string: Routes.API_V2_URL)!)
        SpineHelper.updateHttpHeaders(spine)

        spine.registerValueFormatter(EmbeddedObjectFormatter())
        spine.registerValueFormatter(EmbeddedObjectsFormatter())
        spine.registerValueFormatter(EmbeddedDictFormatter())
        spine.registerValueFormatter(VideoStreamFormatter())
        spine.registerValueFormatter(DualStreamFormatter())

        spine.registerResource(ChannelSpine)
        spine.registerResource(CourseSpine)
        spine.registerResource(CourseEnrollmentSpine)
        spine.registerResource(CourseItemSpine)
        spine.registerResource(CourseSectionSpine)
        spine.registerResource(CourseDateSpine)
        spine.registerResource(ContentSpine)
        spine.registerResource(LTIExerciseSpine)
        spine.registerResource(PeerAssessmentSpine)
        spine.registerResource(PlatformEventSpine)
        spine.registerResource(QuizSpine)
        spine.registerResource(QuizQuestionSpine)
        spine.registerResource(RichTextSpine)
        spine.registerResource(VideoSpine)
        spine.registerResource(NewsArticleSpine)
        spine.registerResource(TrackingEvent)

        let nsCenter = NSNotificationCenter.defaultCenter()
        nsCenter.addObserver(SpineHelper.self, selector: #selector(SpineHelper.updateAfterLoginLogout), name: NotificationKeys.loginSuccessfulKey, object: nil)
        nsCenter.addObserver(SpineHelper.self, selector: #selector(SpineHelper.updateAfterLoginLogout), name: NotificationKeys.logoutSuccessfulKey, object: nil)

        return spine
    }()

    @objc private static func updateAfterLoginLogout() {
        updateHttpHeaders(client)
    }

    private static func updateHttpHeaders(spine: Spine) {
        let httpClient = spine.networkClient as! HTTPClient
        NetworkHelper.getRequestHeaders().forEach { key, value in
            httpClient.setHeader(key, to: value)
        }
    }

    static func findAll<T: Resource>(type: T.Type) -> Future<[T], XikoloError> {
        return client.findAll(type).map { resources, _, _ in
            return resources.map { $0 as! T }
        }.mapError(mapXikoloError)
    }

    static func find<T: Resource>(query: Query<T>) -> Future<[T], XikoloError> {
        return client.find(query).map { resources, _, _ in
            return resources.map { $0 as! T }
        }.mapError(mapXikoloError)
    }

    static func findOne<T: Resource>(id: String, ofType type: T.Type) -> Future<T, XikoloError> {
        return client.findOne(id, ofType: type).map { resource, _, _ in
            return resource
        }.mapError(mapXikoloError)
    }

    static func findOne<T: Resource>(query: Query<T>) -> Future<T, XikoloError> {
        return client.findOne(query).map { resource, _, _ in
            return resource
        }.mapError(mapXikoloError)
    }

    static func save<T: Resource>(resource: T) -> Future<T, XikoloError> {
        return client.save(resource).mapError(mapXikoloError)
    }

    private static func mapXikoloError(error: SpineError) -> XikoloError {
        return XikoloError.API(error)
    }

}
