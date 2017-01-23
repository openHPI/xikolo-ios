use_frameworks!

def common_pods
    pod 'Alamofire', '4.3.0'
    pod 'AlamofireObjectMapper', '4.0.1'
    pod 'ObjectMapper', '2.0'

    pod 'BrightFutures', '5.1.0'
    pod 'Result', '3.1.0'
    pod 'Spine', :git => 'https://github.com/wvteijlingen/Spine.git', :commit => 'ee1ad2b'

    pod 'TSMarkdownParser', :git => 'https://github.com/laptobbe/TSMarkdownParser.git', :commit => 'cff997a'
end

def ios_pods
    pod 'Down', '0.3'
    pod 'PinpointKit', :git => 'https://github.com/Lickability/PinpointKit', :commit => 'dd5731c'
    pod 'DZNEmptyDataSet', '1.8.1'
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
