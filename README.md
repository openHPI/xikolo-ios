<h1 align="center">
    Xikolo iOS App
</h1>

<img align="center" src="assets/banner.png?raw=true" alt="xikolo-ios banner" width="933" />


<p align="center">
    iOS application for openHPI, openSAP, mooc.house, lernen.cloud and OpenWHO
</p>

### Development toolchain
- Xcode 11.5
- bundler: `gem install bundler`

The following tools will be installed via bundler:
- [CocoaPods](https://cocoapods.org/)
- [fastlane](https://fastlane.tools/)

The following tools will be installed via CocoaPods:
- [SwiftLint](https://github.com/realm/SwiftLint)
- [BartyCrouch](https://github.com/Flinesoft/BartyCrouch)

## How to get started
- clone this repository
- run `bundle install`
- run `bundle exec pod repo update` and `bundle exec pod install`
- run `cp -R ./iOS/Branding/openHPI/assets-ios-brand.xcassets ./iOS/assets-ios-brand.generated.xcassets`
- open xikolo-ios.xcworkspace in Xcode
- start one of the defined targets

### Setup testing
- Create the initial credentials file `cp iOS-UITests/Credentials.plist.dummy iOS-UITests/Credentials.plist` (to avoid build errors on the first test run)
- Create the default credentials file `cp iOS-UITests/Credentials.plist.dummy iOS-UITests/Credentials-default.plist`
    - To create a brand specific credentials plist `cp iOS-UITests/Credentials.plist.dummy iOS-UITests/Credentials-<BRAND_NAME>.plist`
- Enter your login credentials for testing in `Credentials-default.plist`

## Contribute to _xikolo-ios_
Check out [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## Code of Conduct
Help us keep this project open and inclusive. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## License
This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.
