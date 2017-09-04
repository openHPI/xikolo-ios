[![Build Status](https://travis-ci.org/openHPI/xikolo-ios.svg?branch=master)](https://travis-ci.org/openHPI/xikolo-ios)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# xikolo-ios
iOS application for openHPI, openSAP, mooc.house and OpenWHO

### Development toolchain
- Xcode 8.3
- [CocoaPods](https://cocoapods.org/) 1.3.1
- [fastlane](https://fastlane.tools/) >= 2.54.3

### How to get started
- clone this repository
- run `pod repo update` and `pod install`
- open xikolo-ios.xcworkspace in Xcode
- start one of the defined targets

#### Setup fastlane
- make your own Appfile via `cp fastlane/Appfile.dummy fastlane/Appfile`
- set the following values
  - `apple_id`
  - `itunes_connect_id` (if required)
- for all available fastlane commands have a look at the [fastlane Readme](https://github.com/openHPI/xikolo-ios/tree/master/fastlane/)
- some commands require setting the app environment via `--env {openhpi|opensap|moochouse|openwho}`

### Contributing
If you would like to contribute by adding a feature or fixing a bug, feel free to do so. You can have a look at the open issues to get some inspiration and create a pull request as soon as you are ready to go.

### Code formatting
In order to have a consistent code formatting, we would like you to set some settings:
- for less unneccessary whitespace changes please set both checkboxes in Xcode->Preferences->Text Editing regarding whitespaces
- use Unix-style line endings (LF)
