fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios increment_version_patch
```
fastlane ios increment_version_patch
```
Increments the version number for a new patch version
### ios increment_version_minor
```
fastlane ios increment_version_minor
```
Increments the version number for a new minor version
### ios increment_version_major
```
fastlane ios increment_version_major
```
Increments the version number for a new major version
### ios determine_commit
```
fastlane ios determine_commit
```
Determines the commit for a given build number

- pass build number via 'build_number:xxx'
### ios lint
```
fastlane ios lint
```
Lint swift code with swiftline
### ios localize
```
fastlane ios localize
```
Adds localizations for the application incrementally

- uses bartycrouch

- translates storyboard files and NSLocalizedString usages
### ios check
```
fastlane ios check
```
Checks application for potential App Store violations
### ios screenshots
```
fastlane ios screenshots
```
Create screenshots for all applications
### ios check_openhpi
```
fastlane ios check_openhpi
```

### ios screenshots_openhpi
```
fastlane ios screenshots_openhpi
```

### ios check_opensap
```
fastlane ios check_opensap
```

### ios screenshots_opensap
```
fastlane ios screenshots_opensap
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
