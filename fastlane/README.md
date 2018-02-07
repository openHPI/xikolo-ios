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
### ios screenshots
```
fastlane ios screenshots
```
Create screenshots for all applications
### ios make_screenshots_openhpi
```
fastlane ios make_screenshots_openhpi
```

### ios make_screenshots_opensap
```
fastlane ios make_screenshots_opensap
```

### ios make_screenshots_openwho
```
fastlane ios make_screenshots_openwho
```

### ios make_screenshots_moochouse
```
fastlane ios make_screenshots_moochouse
```

### ios upload_screenshots
```
fastlane ios upload_screenshots
```
Upload only screenshots to iTunesConnect

No upload of screenshots or IPA
### ios upload_screenshots_openhpi
```
fastlane ios upload_screenshots_openhpi
```

### ios upload_screenshots_opensap
```
fastlane ios upload_screenshots_opensap
```

### ios upload_screenshots_openwho
```
fastlane ios upload_screenshots_openwho
```

### ios upload_screenshots_moochouse
```
fastlane ios upload_screenshots_moochouse
```

### ios upload_metadata
```
fastlane ios upload_metadata
```
Upload only metadata to iTunesConnect

No upload of screenshots or IPA
### ios upload_metadata_openhpi
```
fastlane ios upload_metadata_openhpi
```

### ios upload_metadata_opensap
```
fastlane ios upload_metadata_opensap
```

### ios upload_metadata_openwho
```
fastlane ios upload_metadata_openwho
```

### ios upload_metadata_moochouse
```
fastlane ios upload_metadata_moochouse
```

### ios release
```
fastlane ios release
```
Build and upload only IPA and metadata to iTunesConnect

No upload of screenshots
### ios release_openhpi
```
fastlane ios release_openhpi
```

### ios release_opensap
```
fastlane ios release_opensap
```

### ios release_openwho
```
fastlane ios release_openwho
```

### ios release_moochouse
```
fastlane ios release_moochouse
```

### ios beta
```
fastlane ios beta
```
Build and upload only IPA (beta) to iTunesConnect

No upload of screenshots or metadata
### ios beta_openhpi
```
fastlane ios beta_openhpi
```

### ios beta_opensap
```
fastlane ios beta_opensap
```

### ios beta_openwho
```
fastlane ios beta_openwho
```

### ios beta_moochouse
```
fastlane ios beta_moochouse
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
