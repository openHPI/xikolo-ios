//
//  VideoPlayerControlView.swift
//  xikolo-ios
//
//  Created by Max Bothe on 21/07/17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BMPlayer

class VideoPlayerControlView: BMPlayerControlView {

    override func customizeUIComponents() {
        self.chooseDefitionView.removeFromSuperview()
    }

}
