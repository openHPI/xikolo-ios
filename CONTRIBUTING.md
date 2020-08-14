# Contributing to _xikolo-ios_

### I want to report a problem or ask a question
Before submitting a new GitHub issue, please make sure to check the [existing GitHub issues](https://github.com/openHPI/xikolo-ios/issues). If this doesn't help, please [submit an issue](https://github.com/openHPI/xikolo-ios/issues/new/choose) on GitHub and provide detailed information.

### I want to contribute
Check out the [good first issues](https://github.com/openHPI/xikolo-ios/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) or any other unsassigned issue and submit a pull request when you are ready.

## Programming Guidelines

### Fastlane
We use [fastlane](https://github.com/fastlane/fastlane) for repetitive tasks. Have a look at the [fastlane README](fastlane/README.md).

### Code Formatting
In order to have a consistent code formatting, we would like you to set some settings:
- for less unneccessary whitespace changes please set both checkboxes in Xcode->Preferences->Text Editing regarding whitespaces
- use Unix-style line endings (LF)

### R.swift
We use [R.swift](https://github.com/mac-cain13/R.swift) to keep a certain level of code quality. The linter will run for every pull request and there is also a fastlane command for this.

#### Using self
One thing we can't enforce with R.swift is not to omit `self`. We prefer writing `self` explicitly because we believe this helps to distinguish between member attributes and local variabels.

### Localization
We use [BartyCrouch](https://github.com/Flinesoft/BartyCrouch) to ensure a complete localization of the applications. Simple run `bundle exec fastlane localize` to add entries for missing localizations in storyboard files and `NSLocalizedString` usages. Here are some tips to promote a consistent usage:

#### Exlusion of Storyboard Elements
Add `#bc-ignore!` to 'Comment For Localizer' box in the utilities pane instead of adding `#bc-ignore!` to the elements value.
<div>
	<img src="https://github.com/Flinesoft/BartyCrouch/blob/main/Images/IB-Comment-Exclusion-Example1.png" width="255px" height="437px">
	<img src="https://github.com/Flinesoft/BartyCrouch/blob/main/Images/IB-Comment-Exclusion-Example2.png" width="254px" height="140px">
</div>

#### Support of stringsdict Files
Add `#bc-ignore!` to the user comment of `NSLocalizedString`
```
let format = NSLocalizedString("%d hours", comment: "<number> of hours #bc-ignore!")
```

#### Use Name-Spaced Keys for NSLocalizedString
To add more context to single localized strings, we use name-spaced keys instead of the english text. The english text is stored in `Localizable.strings (Base)`. In this way we also avoid unneccesary long localization keys. So, we write:
```swift
NSLocalizedString("course.section-title.my courses", comment: ...)
```
instead of
```swift
NSLocalizedString("My Courses", comment: ...)
```
