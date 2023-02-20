# This Podfile is configured to not integrate with an xcproject, because the
# only thing we are interested in is fetching CLI tools
install! 'cocoapods',
    integrate_targets: false,
    skip_pods_project_generation: true

platform :ios, '11.0'

pod 'BartyCrouch', :git => 'https://github.com/Flinesoft/BartyCrouch.git', :tag => '3.13.0'
pod 'SwiftLint', '~> 0.22'


# Because `post_install` is not called if no targets are specified, we run the custom seyup in `pre_install`
pre_install do |installer|
    Pod::UI.info "Installing BartyCrouch manually"
    system("make installables -C ./Pods/BartyCrouch >> /dev/null")
    system("cp -f /tmp/BartyCrouch.dst/usr/local/bin/bartycrouch ./Pods/BartyCrouch/bartycrouch")

    Pod::UI.info "Downloading Crashlyics 'upload_symbols' to './fastlane/scripts/upload_symbols'"
    system("mkdir -p ./fastlane/scripts")
    system("curl -sL https://github.com/firebase/firebase-ios-sdk/raw/master/Crashlytics/upload-symbols -o ./fastlane/scripts/upload_symbols")
    system("chmod +x ./fastlane/scripts/upload_symbols")
end
