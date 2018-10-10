//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation

extension CoreDataHelper {

    public static func migrateModelToCommon() {
        guard !UserDefaults.standard.didMigrateCoreDataModelToCommon else {
            return
        }

        let nestedResources: [String: [String]] = [
            "Course": ["certificates"],
            "Enrollment": ["certificates"],
            "Video": ["singleStream", "slidesStream", "lecturerStream"],
        ]

        let context = self.persistentContainer.newBackgroundContext()
        context.performAndWait {
            do {
                for (enitityName, attributes) in nestedResources {
                    guard let request = self.attributeResetRequest(for: enitityName, attributes: attributes) else { continue }
                    try context.execute(request)
                }

                if let deleteRequest = self.entityDeleteRequest(for: "TrackingEvent") {
                    try context.execute(deleteRequest)
                }

                UserDefaults.standard.didMigrateCoreDataModelToCommon = true
            } catch {
                ErrorManager.shared.report(error)
            }
        }
    }

    private static func attributeResetRequest(for entityName: String, attributes: [String]) -> NSBatchUpdateRequest? {
        guard let entityDescription = self.persistentContainer.managedObjectModel.entitiesByName[entityName] else {
            return nil
        }

        let attributeNames = entityDescription.attributesByName.keys
        let filteredAttributes = attributes.filter { attributeNames.contains($0) }

        guard !filteredAttributes.isEmpty else {
            return nil
        }

        let propertiesToUpdate = filteredAttributes.reduce(into: [:]) { result, attribute in result[attribute] = "nil" }
        let updateRequest = NSBatchUpdateRequest(entityName: entityName)
        updateRequest.propertiesToUpdate = propertiesToUpdate
        updateRequest.resultType = .updatedObjectsCountResultType
        return updateRequest
    }

    private static func entityDeleteRequest(for entityName: String) -> NSBatchDeleteRequest? {
        guard self.persistentContainer.managedObjectModel.entitiesByName.keys.contains(entityName) else {
            return nil
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        return deleteRequest
    }

}
