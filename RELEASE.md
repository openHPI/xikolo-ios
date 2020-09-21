# How to Release a New Version of the Apps

You have to be part of our core dev team to do this.

## Prerequirements

1. To enable release via fastlane, create your copy of the Appfile
   ```
   cp fastlane/Appfile.dummy fastlane/Appfile
   ```
   Enter values for `apple_id` (your Apple developer account) and `itunes_connect_id` (your Apple account with access to AppStoreConnect). Those two could be the same Apple account.
1. Sensitive files are protected with [`git-crypt`](https://github.com/AGWA/git-crypt/). To compile release builds, [install](https://www.agwa.name/projects/git-crypt/) `git-crypt`:
   ```
   brew install git-crypt
   ```
   And unlock the encrypted files:
   ```
   git-crypt unlock /path/to/xikolo-ios.key
   ```
   The keyfile is managed by our core dev team and should never be made public or added to the repository.

## Release the Apps

There is a fastlane command for each step. One for all flavors and one for each flavor (suffix: `_flavorname`)

1. Retrieve the iOS Distribution Certificate (in person) and the Provisioning Profiles (via Xcode, you must be part of our development team)
1. Update metadata (especially the release notes) in `fastlane/metadata` (fastlane will create a new version in iTunesConnect)
1. Optional: Create app screenshots via `fastlane make_screenshots`
1. Upload metadata via `fastlane upload_metadata`
1. Optional: Upload screenshots via `fastlane upload_screenschots`
1. Upload IPA via `fastlane release`
1. Wait until iTunesConnect has processed the build
1. Assign the build to the release manually
1. Submit the release to review manually
1. Create a GitHub release (incl. git tag) for the release via `fastlane tag_release`
1. Refresh the dSYM files on Firebase for the current app version via `fastlane refresh_dsyms`
