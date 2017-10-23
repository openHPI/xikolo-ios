use_frameworks!
inhibit_all_warnings!

pod 'BartyCrouch', :git => 'https://github.com/mathebox/BartyCrouch.git', :commit => 'cf75991'

def common_pods
    # can be remove 
    pod 'Alamofire', '4.3.0'
    pod 'AlamofireObjectMapper', '4.0.1'
    pod 'ObjectMapper', '2.0'
    pod 'Result', '~> 3.2'
    pod 'Spine', :git => 'https://github.com/mathebox/Spine.git', :commit => 'ce6a53f'

    pod 'BrightFutures', '~> 6.0'
    pod 'Down', :git => 'https://github.com/iwasrobbed/Down', :commit => '18eb466'
    pod 'KeychainAccess', '~> 3.1'
    pod 'Marshal', '~> 1.2'
    pod 'SDWebImage/Core', '4.0.0'
end

def ios_pods
    pod 'BMPlayer', '~> 1.0'
    pod 'DownloadButton', '0.1.0'
    pod 'DZNEmptyDataSet', '1.8.1'
    pod 'Hero', :git => 'https://github.com/lkzhao/Hero', :commit => 'd961f16'
    pod 'Shimmer', '1.0.2'
    pod 'ReachabilitySwift', '3'
end

target 'openHPI-iOS' do
    platform :ios, '10.0'
    common_pods
    ios_pods
end

target 'openHPI-tvOS' do
    platform :tvos, '10.0'
    common_pods
end

target 'openHPI-tvOS-TopShelf' do
    platform :tvos, '10.0'
    common_pods
end

target 'openSAP-iOS' do
    platform :ios, '10.0'
    common_pods
    ios_pods
end

target 'openSAP-tvOS' do
    platform :tvos, '10.0'
    common_pods
end

target 'openSAP-tvOS-TopShelf' do
    platform :tvos, '10.0'
    common_pods
end

target 'openWHO-iOS' do
    platform :ios, '10.0'
    common_pods
    ios_pods
end

target 'openWHO-tvOS' do
    platform :tvos, '10.0'
    common_pods
end

target 'openWHO-tvOS-TopShelf' do
    platform :tvos, '10.0'
    common_pods
end

target 'moocHOUSE-iOS' do
    platform :ios, '10.0'
    common_pods
    ios_pods
end

target 'moocHOUSE-tvOS' do
    platform :tvos, '10.0'
    common_pods
end

target 'moocHOUSE-tvOS-TopShelf' do
    platform :tvos, '10.0'
    common_pods
end

post_install do |installer|
    system("make installables -C ./Pods/BartyCrouch")
    system("cp -f /tmp/BartyCrouch.dst/usr/local/bin/bartycrouch ./Pods/BartyCrouch/bartycrouch")
end
