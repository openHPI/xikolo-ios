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

# How to Release a New Version of the Apps
You have to be part of out core dev team to do this.

### Prerequirements:
1. To enable release via fastlane, create your copy of the Appfile
   ```
   cp fastlane/Appfile.dummy fastlane/Appfile
   ```
   Enter values for `apple_id` (your Apple developer account) and `itunes_connect_id` (your Apple Account with access to AppStoreConnect). Those two could be the same Apple account.
1. Sensitive files are protected with [`git-crypt`](https://github.com/AGWA/git-crypt/). To compile release builds, [install](https://www.agwa.name/projects/git-crypt/) `git-crypt`:
   ```
   brew install git-crypt
   ```
   And unlock the encrypted files:
   ```
   git-crypt unlock /path/to/xikolo-ios.key
   ```
   The keyfile is managed by the openHPI team and should never be made public or added to the repository.

### Release the Apps
There is a fastlane command for each step. One for all flavor and one for each flavor (suffix: `_flavorname`)

1. Retrieve the iOS Distribution Certificate (in person) and the Provisioning Profiles (via Xcode, you must be part of our development team)
1. Update metadata (especially the release notes) in `fastlane/metadata` (fastlane will create a new version in iTunesConnect)
1. Optional: Create app screenshots via `fastlane make_screenshots`
1. Upload metadata via `fastlane upload_metadata`
1. Optional: Upload screenshots via `fastlane upload_screenschots`
1. Upload IPA via `fastlane release`
1. Wait until iTunesConnect has processed the build
1. Assign the build to the release manually
1. Submit the release to review manually
1. Create a github release (incl. git tag) for the release via `fastlane tag_release`
1. Refresh the dSYM files on Firebase for the current app version via `fastlane refresh_dsyms`
