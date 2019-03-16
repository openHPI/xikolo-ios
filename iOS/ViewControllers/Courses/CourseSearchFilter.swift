//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

enum CourseSearchFilterType: CaseIterable {
    case language

    var title: String {
        switch self {
        case .language:
            return "Language"
        }
    }

    static var availableFilterTypes: [CourseSearchFilterType] {
        return CourseSearchFilterType.allCases
    }

}

protocol CourseSearchFilter {
    var counterValue: Int { get }
    var predicate: NSPredicate { get }
}

struct CourseLanguageSearchFilter: CourseSearchFilter {

    let languages: [String]

    var counterValue: Int {
        return self.languages.count
    }

    var predicate: NSPredicate {
        #warning("use really CONTAINS[c] ?")
        let languagePredicates = self.languages.map { NSPredicate(format: "language CONTAINS[c] %@", $0) }
        return NSCompoundPredicate(orPredicateWithSubpredicates: languagePredicates)
    }

}
