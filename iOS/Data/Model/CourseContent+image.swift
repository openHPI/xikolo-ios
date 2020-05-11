//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension CourseItem {

    var image: UIImage? {
        switch self.icon {
        case "bonus_lti_exercise":
            return R.image.courseItemIcons.bonusLtiExercise()
        case "bonus_quiz":
            return R.image.courseItemIcons.bonusQuiz()
        case "chart":
            return R.image.courseItemIcons.chart()
        case "document":
            return R.image.courseItemIcons.document()
        case "external_video":
            return R.image.courseItemIcons.externalVideo()
        case "homework":
            return R.image.courseItemIcons.homework()
        case "lti_exercise":
            return R.image.courseItemIcons.ltiExercise()
        case "quiz":
            return R.image.courseItemIcons.quiz()
        case "rich_text":
            return R.image.courseItemIcons.richText()
        case "survey":
            return R.image.courseItemIcons.survey()
        case "video":
            return R.image.courseItemIcons.video()
        case "youtube":
            return R.image.courseItemIcons.youtube()
        default:
            return R.image.courseItemIcons.document()
        }
    }

}
