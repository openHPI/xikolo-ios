use_frameworks!

def common_pods
    pod 'Alamofire', '3.2.0'
    pod 'AlamofireObjectMapper', '3.0.0'
    pod 'ObjectMapper', '1.0.0'

    pod 'BrightFutures', '4.0.0'
    pod 'Result', '2.0.0'
    pod 'Spine', :git => 'https://github.com/wvteijlingen/Spine.git', :commit => '53971cf'

    pod 'TSMarkdownParser', :git => 'https://github.com/laptobbe/TSMarkdownParser.git', :commit => 'cff997a'
end

def ios_pods
    pod 'Down', :git => 'https://github.com/iwasrobbed/Down.git', :commit => 'ae3161c'
    pod 'PinpointKit', '~> 0.9'
end

target 'openHPI-iOS' do
    platform :ios, '9.0'
    common_pods
    ios_pods

end

target 'openHPI-tvOS' do
    platform :tvos, '9.0'
    common_pods

end

target 'openHPI-tvOS-TopShelf' do
    platform :tvos, '9.0'
    common_pods

end

target 'openSAP-iOS' do
    platform :ios, '9.0'
    common_pods
    ios_pods

end

target 'openSAP-tvOS' do
    platform :tvos, '9.0'
    common_pods

end

target 'openSAP-tvOS-TopShelf' do
    platform :tvos, '9.0'
    common_pods

end

target 'openWHO-iOS' do
    platform :ios, '9.0'
    common_pods
    ios_pods

end

target 'openWHO-tvOS' do
    platform :tvos, '9.0'
    common_pods

end

target 'openWHO-tvOS-TopShelf' do
    platform :tvos, '9.0'
    common_pods

end
