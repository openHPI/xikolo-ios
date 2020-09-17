# How to Contribute

### I want to report a problem or ask a question
Before submitting a new GitHub issue, please make sure to check the [existing GitHub issues](https://github.com/openHPI/xikolo-ios/issues). If this doesn't help, please [submit an issue](https://github.com/openHPI/xikolo-ios/issues/new/choose) on GitHub and provide detailed information.

### I want to contribute
Check out the [good first issues](https://github.com/openHPI/xikolo-ios/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) or any other unassigned issue and submit a pull request when you are ready.

## Programming Guidelines

### Fastlane
We use [fastlane](https://github.com/fastlane/fastlane) for repetitive tasks. Have a look at the [fastlane README](fastlane/README.md).

#### Useful Commands When Developing
These custom commands ease the development process.

- `bundle exec fastlane lint`: Report linting warnings for the project (via swiftlint)
- `bundle exec fastlane format`: Resolve linting warning for the project -- not applicable to all warnings (via swiftlint)
- `bundle exec fastlane localize`: Extract keys for localized strings and add them to the respective `.strings` files (via BartyCrouch)
- `bundle exec fastlane check_core_data`: Check if the core data model was modified since the last tagged release
- `bundle exec fastlane increment_version_(patch|minor|major)`: Increase the app version project-wide in all modules
- `bundle exec fastlane changelog`: List all commits since the last tagged release
- `bundle exec fastlane export_localizations`: Export localizations and strip unwanted strings, that are excluded by BartyCrouch

### Code Formatting
In order to have a consistent code formatting, we would like you to set some settings:
- For fewer unneccessary whitespace changes, please select the following options in `Xcode > Preferences > Text Editing > Editing` (as of Xcode 12)
  - Check box for `Automatically trim trailing whitespace`
  - Check box for `Including whitespac-eonly lines`
  - Choose `Unicode (UTF-8)` for `Defautl Text Encoding`
  - Choose `macOS / Unix (LF)` for `Default Line Endings`

### R.swift
We use [R.swift](https://github.com/mac-cain13/R.swift) to avoid static strings in the codebase.

### Using self
One thing we can't enforce with R.swift is not to omit `self`. We prefer writing `self` explicitly because we believe this helps to distinguish between member attributes and local variabels.

For example:

```swift 
class ChannelCell: UICollectionViewCell {

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var channelImage: UIImageView!

    // ...

    override func awakeFromNib() {
        super.awakeFromNib()

        self.shadowView.layer.roundCorners(for: .default, masksToBounds: false)
        self.channelImage.layer.roundCorners(for: .default)
        self.channelImage.backgroundColor = Brand.default.colors.secondary

        self.shadowView.addDefaultPointerInteraction()
    }

    // ...
}
```

instead of 

```swift 
class ChannelCell: UICollectionViewCell {

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var channelImage: UIImageView!

    // ...

    override func awakeFromNib() {
        super.awakeFromNib()

        shadowView.layer.roundCorners(for: .default, masksToBounds: false)
        channelImage.layer.roundCorners(for: .default)
        channelImage.backgroundColor = Brand.default.colors.secondary

        shadowView.addDefaultPointerInteraction()
    }

    // ...
}
```

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
```swift
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
