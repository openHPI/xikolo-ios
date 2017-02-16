//
//  ErrorHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 18.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

extension UIViewController {

    func handleError(_ message: String) -> ((_ error: XikoloError) -> ()) {
        return { error in
            let title = NSLocalizedString("Error", comment: "Error")
            let ok = NSLocalizedString("OK", comment: "OK")

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ok, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func handleError(_ error: XikoloError) {
        var message: String!
        switch (error) {
            case .api, .network:
                message = NSLocalizedString("A network error occurred. Please try again later.", comment: "A network error occurred. Please try again later.")
            default:
                message = NSLocalizedString("An unknown error occurred. Please try again later.", comment: "An unknown error occurred. Please try again later.")
        }
        handleError(message)(error)
    }

}
