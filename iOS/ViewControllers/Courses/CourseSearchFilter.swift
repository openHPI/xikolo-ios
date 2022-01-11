//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import UIKit

enum CourseSearchFilter: CaseIterable {
    case language
    case category
    case topic

    var isAvailable: Bool {
        switch self {
        case .language:
            return true
        case .category:
            return Brand.default.courseClassifierSearchFilters?.category != nil
        case .topic:
            return Brand.default.courseClassifierSearchFilters?.topic != nil
        }
    }

    var title: String? {
        switch self {
        case .language:
            return NSLocalizedString("course-list.search.filter.title.language", comment: "Title for language filter")
        case .category:
            return Brand.default.courseClassifierSearchFilters?.category?.displayName
        case .topic:
            return Brand.default.courseClassifierSearchFilters?.topic?.displayName
        }
    }

    var allOptionsActivatedByDefault: Bool {
        switch self {
        case .language:
            return true
        case .category:
            return false
        case .topic:
            return false
        }
    }

    func options() -> [String] {
        switch self {
        case .language:
            let fetchRequest = CourseHelper.FetchRequest.distinctLanguages
            let dicts = try? CoreDataHelper.viewContext.fetch(fetchRequest)
            let allValues = dicts?.flatMap(\.allValues).compactMap { $0 as? String } ?? []
            let preferredLocalizations = Bundle.preferredLocalizations(from: allValues)
            let otherLocalizations = allValues.filter { !preferredLocalizations.contains($0) }
            return preferredLocalizations + otherLocalizations
        case .category:
            let fetchRequest = CourseHelper.FetchRequest.categories
            let dicts = try? CoreDataHelper.viewContext.fetch(fetchRequest)
            return self.extractUniqueValues(from: dicts)
        case .topic:
            let fetchRequest = CourseHelper.FetchRequest.topics
            let dicts = try? CoreDataHelper.viewContext.fetch(fetchRequest)
            return self.extractUniqueValues(from: dicts)
        }
    }

    private func extractUniqueValues(from dicts: [NSDictionary]?) -> [String] {
        let combinedValues = dicts?.flatMap(\.allValues).compactMap { $0 as? String }
        let values = combinedValues?.compactMap(Course.arrayValues).flatMap { $0 }
        let valueSet = Set(values ?? [])
        return Array(valueSet).sorted()
    }

    func title(for option: String) -> String? {
        switch self {
        case .language:
            return LanguageLocalizer.nativeDisplayName(for: option)
        default:
            return option
        }
    }

    func subtitle(for option: String) -> String? {
        switch self {
        case .language:
            return LanguageLocalizer.localizedDisplayName(for: option)
        default:
            return nil
        }
    }

    func predicate(forSelectedOptions selectedOptions: Set<String>) -> NSPredicate {
        switch self {
        case .language:
            let languagePredicates = selectedOptions.map { NSPredicate(format: "language == %@", $0) }
            return NSCompoundPredicate(orPredicateWithSubpredicates: languagePredicates)
        case .category:
            let categoryPredicates = selectedOptions.map { NSPredicate(format: "categories CONTAINS[c] %@", $0) }
            return NSCompoundPredicate(orPredicateWithSubpredicates: categoryPredicates)
        case .topic:
            let topicPredicates = selectedOptions.map { NSPredicate(format: "topics CONTAINS[c] %@", $0) }
            return NSCompoundPredicate(orPredicateWithSubpredicates: topicPredicates)
        }
    }

    static var availableCases: [CourseSearchFilter] {
        return Self.allCases.filter(\.isAvailable)
    }
}
