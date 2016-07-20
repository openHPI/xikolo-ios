use_frameworks!

def common_pods
    pod 'Alamofire'
    pod 'AlamofireObjectMapper'

    pod 'BrightFutures'
    pod 'Result'
    pod 'Spine', :git => 'https://github.com/wvteijlingen/Spine.git', :branch => 'master'

    pod 'TSMarkdownParser', :git => 'https://github.com/laptobbe/TSMarkdownParser.git', :branch => 'master'
end

target 'openHPI-iOS' do
    platform :ios, '9.0'
    common_pods

end

target 'openHPI-tvOS' do
    platform :tvos, '9.0'
    common_pods

end

target 'openHPI-tvOS-TopShelf' do
    platform :tvos, '9.0'
    common_pods

end
