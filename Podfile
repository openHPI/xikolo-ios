use_frameworks!

def common_pods
    # Reactive Programming
    pod 'RxSwift', :git => "https://github.com/ReactiveX/RxSwift.git"
    pod 'RxCocoa', :git => "https://github.com/ReactiveX/RxSwift.git"

    # JSON Parsing
    pod 'SwiftyJSON', :git => "https://github.com/SwiftyJSON/SwiftyJSON.git"

    pod 'Alamofire'
    pod 'AlamofireObjectMapper'
end

target 'xikolo-ios' do
    platform :ios, '9.0'
    common_pods

end

target 'xikolo-iosTests' do
    platform :ios, '9.0'

end

target 'xikolo-iosUITests' do
    platform :ios, '9.0'

end

target 'xikolo-tvos' do
    platform :tvos, '9.0'
    common_pods

end

target 'xikolo-tvosUITests' do
    platform :tvos, '9.0'

end
