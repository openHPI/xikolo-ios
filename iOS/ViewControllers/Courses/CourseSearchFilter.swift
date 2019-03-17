//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

protocol CourseSearchFilter{
    static var title: String { get }
    static var options: [String] { get }

    var counterValue: Int { get }
    var predicate: NSPredicate { get }

    init(selectedOptions: [String])
}

struct CourseLanguageSearchFilter: CourseSearchFilter {

    static let title: String = "Language"
    static var options: [String] {
        #warning("Determine options")
        return ["de", "en"]
    }

    let languages: [String]

    var counterValue: Int {
        return self.languages.count
    }

    var predicate: NSPredicate {
        #warning("use really CONTAINS[c] ?")
        let languagePredicates = self.languages.map { NSPredicate(format: "language CONTAINS[c] %@", $0) }
        return NSCompoundPredicate(orPredicateWithSubpredicates: languagePredicates)
    }

    init(selectedOptions: [String]) {
        self.languages = selectedOptions
    }

}
