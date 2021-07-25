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
or alternatively using `brew install fastlane`

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
Lint swift code with swiftlint
### ios format
```
fastlane ios format
```
Format swift code with swiftlint
### ios localize
```
fastlane ios localize
```
Adds localizations for the application incrementally

- uses bartycrouch

- translates storyboard files and NSLocalizedString usages
### ios make_screenshots
```
fastlane ios make_screenshots
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

### ios make_screenshots_lernencloud
```
fastlane ios make_screenshots_lernencloud
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

### ios upload_screenshots_lernencloud
```
fastlane ios upload_screenshots_lernencloud
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

### ios upload_metadata_lernencloud
```
fastlane ios upload_metadata_lernencloud
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

### ios release_lernencloud
```
fastlane ios release_lernencloud
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

### ios beta_lernencloud
```
fastlane ios beta_lernencloud
```

### ios tag_release
```
fastlane ios tag_release
```

### ios refresh_dsyms
```
fastlane ios refresh_dsyms
```
Download dSYMS files from iTunesConnect and upload them to Firebase
### ios refresh_dsyms_openhpi
```
fastlane ios refresh_dsyms_openhpi
```

### ios refresh_dsyms_opensap
```
fastlane ios refresh_dsyms_opensap
```

### ios refresh_dsyms_openwho
```
fastlane ios refresh_dsyms_openwho
```

### ios refresh_dsyms_moochouse
```
fastlane ios refresh_dsyms_moochouse
```

### ios refresh_dsyms_lernencloud
```
fastlane ios refresh_dsyms_lernencloud
```

### ios changelog
```
fastlane ios changelog
```

### ios check_core_data
```
fastlane ios check_core_data
```
Check if the core data model was modified since the last release
### ios export_localizations
```
fastlane ios export_localizations
```
Export localizations and strip unwanted strings

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
