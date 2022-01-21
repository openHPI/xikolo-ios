fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios increment_version_patch

```sh
[bundle exec] fastlane ios increment_version_patch
```

Increments the version number for a new patch version

### ios increment_version_minor

```sh
[bundle exec] fastlane ios increment_version_minor
```

Increments the version number for a new minor version

### ios increment_version_major

```sh
[bundle exec] fastlane ios increment_version_major
```

Increments the version number for a new major version

### ios determine_commit

```sh
[bundle exec] fastlane ios determine_commit
```

Determines the commit for a given build number

- pass build number via 'build_number:xxx'

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Lint swift code with swiftlint

### ios format

```sh
[bundle exec] fastlane ios format
```

Format swift code with swiftlint

### ios localize

```sh
[bundle exec] fastlane ios localize
```

Adds localizations for the application incrementally

- uses bartycrouch

- translates storyboard files and NSLocalizedString usages

### ios make_screenshots

```sh
[bundle exec] fastlane ios make_screenshots
```

Create screenshots for all applications

### ios make_screenshots_openhpi

```sh
[bundle exec] fastlane ios make_screenshots_openhpi
```



### ios make_screenshots_opensap

```sh
[bundle exec] fastlane ios make_screenshots_opensap
```



### ios make_screenshots_openwho

```sh
[bundle exec] fastlane ios make_screenshots_openwho
```



### ios make_screenshots_moochouse

```sh
[bundle exec] fastlane ios make_screenshots_moochouse
```



### ios make_screenshots_lernencloud

```sh
[bundle exec] fastlane ios make_screenshots_lernencloud
```



### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload only screenshots to iTunesConnect

No upload of screenshots or IPA

### ios upload_screenshots_openhpi

```sh
[bundle exec] fastlane ios upload_screenshots_openhpi
```



### ios upload_screenshots_opensap

```sh
[bundle exec] fastlane ios upload_screenshots_opensap
```



### ios upload_screenshots_openwho

```sh
[bundle exec] fastlane ios upload_screenshots_openwho
```



### ios upload_screenshots_moochouse

```sh
[bundle exec] fastlane ios upload_screenshots_moochouse
```



### ios upload_screenshots_lernencloud

```sh
[bundle exec] fastlane ios upload_screenshots_lernencloud
```



### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload only metadata to iTunesConnect

No upload of screenshots or IPA

### ios upload_metadata_openhpi

```sh
[bundle exec] fastlane ios upload_metadata_openhpi
```



### ios upload_metadata_opensap

```sh
[bundle exec] fastlane ios upload_metadata_opensap
```



### ios upload_metadata_openwho

```sh
[bundle exec] fastlane ios upload_metadata_openwho
```



### ios upload_metadata_moochouse

```sh
[bundle exec] fastlane ios upload_metadata_moochouse
```



### ios upload_metadata_lernencloud

```sh
[bundle exec] fastlane ios upload_metadata_lernencloud
```



### ios release

```sh
[bundle exec] fastlane ios release
```

Build and upload only IPA and metadata to iTunesConnect

No upload of screenshots

### ios release_openhpi

```sh
[bundle exec] fastlane ios release_openhpi
```



### ios release_opensap

```sh
[bundle exec] fastlane ios release_opensap
```



### ios release_openwho

```sh
[bundle exec] fastlane ios release_openwho
```



### ios release_moochouse

```sh
[bundle exec] fastlane ios release_moochouse
```



### ios release_lernencloud

```sh
[bundle exec] fastlane ios release_lernencloud
```



### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload only IPA (beta) to iTunesConnect

No upload of screenshots or metadata

### ios beta_openhpi

```sh
[bundle exec] fastlane ios beta_openhpi
```



### ios beta_opensap

```sh
[bundle exec] fastlane ios beta_opensap
```



### ios beta_openwho

```sh
[bundle exec] fastlane ios beta_openwho
```



### ios beta_moochouse

```sh
[bundle exec] fastlane ios beta_moochouse
```



### ios beta_lernencloud

```sh
[bundle exec] fastlane ios beta_lernencloud
```



### ios tag_release

```sh
[bundle exec] fastlane ios tag_release
```



### ios refresh_dsyms

```sh
[bundle exec] fastlane ios refresh_dsyms
```

Download dSYMS files from iTunesConnect and upload them to Firebase

### ios refresh_dsyms_openhpi

```sh
[bundle exec] fastlane ios refresh_dsyms_openhpi
```



### ios refresh_dsyms_opensap

```sh
[bundle exec] fastlane ios refresh_dsyms_opensap
```



### ios refresh_dsyms_openwho

```sh
[bundle exec] fastlane ios refresh_dsyms_openwho
```



### ios refresh_dsyms_moochouse

```sh
[bundle exec] fastlane ios refresh_dsyms_moochouse
```



### ios refresh_dsyms_lernencloud

```sh
[bundle exec] fastlane ios refresh_dsyms_lernencloud
```



### ios changelog

```sh
[bundle exec] fastlane ios changelog
```



### ios check_core_data

```sh
[bundle exec] fastlane ios check_core_data
```

Check if the core data model was modified since the last release

### ios export_localizations

```sh
[bundle exec] fastlane ios export_localizations
```

Export localizations and strip unwanted strings

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
