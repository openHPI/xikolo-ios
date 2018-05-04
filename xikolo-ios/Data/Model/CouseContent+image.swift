//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension CourseItem {

    var image: UIImage? {
        switch self.icon {
        case "bonus_lti_exercise"?:
            return R.image.courseItemIconBonus_lti_exercise()
        case "bonus_quiz"?:
            return R.image.courseItemIconBonus_quiz()
        case "chart"?:
            return R.image.courseItemIconChart()
        case "document"?:
            return R.image.courseItemIconDocument()
        case "external_video"?:
            return R.image.courseItemIconExternal_video()
        case "homework"?:
            return R.image.courseItemIconHomework()
        case "lti_exercise"?:
            return R.image.courseItemIconLti_exercise()
        case "quiz"?:
            return R.image.courseItemIconQuiz()
        case "rich_text"?:
            return R.image.courseItemIconRich_text()
        case "survey"?:
            return R.image.courseItemIconSurvey()
        case "video"?:
            return R.image.courseItemIconVideo()
        case "youtube"?:
            return R.image.courseItemIconYoutube()
        default:
            return R.image.courseItemIconDocument()
        }
    }

}
