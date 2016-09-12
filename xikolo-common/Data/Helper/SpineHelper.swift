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
        let httpClient = spine.networkClient as! HTTPClient

        NetworkHelper.getRequestHeaders().forEach { key, value in
            httpClient.setHeader(key, to: value)
        }

        spine.registerValueFormatter(EmbeddedObjectFormatter())
        spine.registerValueFormatter(EmbeddedObjectsFormatter())
        spine.registerValueFormatter(VideoStreamFormatter())
        spine.registerValueFormatter(DualStreamFormatter())

        spine.registerResource(CourseSpine)
        spine.registerResource(CourseEnrollmentSpine)
        spine.registerResource(CourseItemSpine)
        spine.registerResource(CourseSectionSpine)
        spine.registerResource(ContentSpine)
        spine.registerResource(QuizSpine)
        spine.registerResource(QuizQuestionSpine)
        spine.registerResource(RichTextSpine)
        spine.registerResource(VideoSpine)
        spine.registerResource(NewsArticleSpine)
        spine.registerResource(TrackingEvent)

        return spine
    }()

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
