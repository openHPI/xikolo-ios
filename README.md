[![Build Status](https://travis-ci.org/openHPI/xikolo-ios.svg?branch=master)](https://travis-ci.org/openHPI/xikolo-ios)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# xikolo-ios
iOS application for openHPI, openSAP, mooc.house and OpenWHO

### Development toolchain
- Xcode 9.0
- bundler: `gem install bundler`

The following tools will be installed via bundler:
- [CocoaPods](https://cocoapods.org/)
- [fastlane](https://fastlane.tools/)

The following tools will be installed via cocoapods:
- [BartyCrouch](https://github.com/Flinesoft/BartyCrouch)

### How to get started
- clone this repository
- run `bundle install`
- run `bundle exec pod repo update` and `bundle exec pod install`
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

### Localization
We use [BartyCrouch](https://github.com/Flinesoft/BartyCrouch) to ensure a complete localization of the applications. Simple run `bundle exec fastlane localize` to add entries for missing localizations in storyboard files and `NSLocalizedString` usages. Here are some tips to promote a consistent usage:

#### Exlusion of storyboard elements
Add `#bc-ignore!` to 'Comment For Localizer' box in the utilities pane instead of adding `#bc-ignore!` to the elements value.
<div>
	<img src="https://raw.githubusercontent.com/Flinesoft/BartyCrouch/stable/IB-Comment-Exclusion-Example1.png" width="275px" height="491px">
	<img src="https://raw.githubusercontent.com/Flinesoft/BartyCrouch/stable/IB-Comment-Exclusion-Example2.png" width="272px" height="195px">
</div>

#### Use name-spaced keys for NSLocalizedString
To add more context to single localized strings, we use name-spaced keys instead of the english text. The english text is stored in `Localizable.strings (Base)`. In this way we also avoid unneccesary long localization keys. So, we write:
```swift
NSLocalizedString("course.section-title.my courses", comment: ...)
```
instead of
```swift
NSLocalizedString("My Courses", comment: ...)
```

#### Support of stringsdict files
Add `#bc-ignore!` to the user comment of `NSLocalizedString`
```
let format = NSLocalizedString("%d hours", comment: "<number> of hours #bc-ignore!")
```
