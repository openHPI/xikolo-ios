<h1 align="center">
    xikolo-ios
</h1>

<img align="center" src="assets/banner.png?raw=true" alt="xikolo-ios banner" width="933" />


<p align="center">
    iOS application for openHPI, openSAP, mooc.house and OpenWHO
</p>

<p align="center">
    <a  href="https://travis-ci.org/openHPI/xikolo-ios" target="_blank"><img src="https://travis-ci.org/openHPI/xikolo-ios.svg?branch=dev" /></a>
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" />
</p>


### Development toolchain
- Xcode 11
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
- open xikolo-ios.xcworkspace in Xcode
- start one of the defined targets

### Setup testing
- copy the credentials plist dummy file `cp UI\ Tests/Credentials.plist.dummy UI\ Tests/Credentials.plist`
- enter your login credentials for testing

## Contribute to _xikolo-ios_
Check out [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## Code of Conduct
Help us keep this project open and inclusive. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## License
This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.
