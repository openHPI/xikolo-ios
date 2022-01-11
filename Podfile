# This Podfile is configured to not integrate with an xcproject, because the
# only thing we are interested in is fetching CLI tools
install! 'cocoapods',
    integrate_targets: false,
    skip_pods_project_generation: true

platform :ios, '10.0'

pod 'BartyCrouch', :git => 'https://github.com/Flinesoft/BartyCrouch.git', :tag => '3.13.0'
pod 'R.swift', '~> 5.0'
pod 'SwiftLint', '~> 0.22'

pre_install do |installer|
    # Because `post_install` is not called if no targets are specified, we run this in `pre_install`
    Pod::UI.info "Installing BartyCrouch manually"
    system("make installables -C ./Pods/BartyCrouch >> /dev/null")
    system("cp -f /tmp/BartyCrouch.dst/usr/local/bin/bartycrouch ./Pods/BartyCrouch/bartycrouch")
end
