use_frameworks!
inhibit_all_warnings!

pod 'BartyCrouch', :git => 'https://github.com/mathebox/BartyCrouch.git', :commit => 'cf75991'
pod 'SwiftLint', '~> 0.22'

def common_pods
    pod 'BrightFutures', '~> 6.0'
    pod 'Down', '~> 0.4' #:git => 'https://github.com/iwasrobbed/Down', :commit => '18eb466'
    pod 'KeychainAccess', '~> 3.1'
    pod 'Marshal', '~> 1.2'
    pod 'SDWebImage', '~> 4.2'
end

def ios_pods
    pod 'BMPlayer', :git => 'https://github.com/openHPI/bmplayer.git', :commit => 'a8e110d'
    pod 'DZNEmptyDataSet', '~> 1.8'
    pod 'ReachabilitySwift', '~> 4.1'
    pod 'SimpleRoundedButton', :git => 'https://github.com/mathebox/SimpleRoundedButton.git', :commit => '91225d2'
    pod 'SimulatorStatusMagic', '~> 2.1', :configurations => ['Debug']
    pod 'XCGLogger', '~> 6.0'
    pod 'Alamofire' 

    # Firebase
    pod 'Firebase/Core', '~> 4.8'
    pod 'Fabric', '~> 1.7'
    pod 'Crashlytics', '~> 3.9'
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
    Pod::UI.info "Installing BartyCrouch manually"
    system("make installables -C ./Pods/BartyCrouch --silent")
    system("cp -f /tmp/BartyCrouch.dst/usr/local/bin/bartycrouch ./Pods/BartyCrouch/bartycrouch")

    Pod::UI.info "Fix provisioning profile specifiers"
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
    end

    # This is highly inspired by cocoapods-acknowledgements (https://github.com/CocoaPods/cocoapods-acknowledgements)
    # but creates only one pod license file for iOs instead of one license file for each target
    # Additonally, it provides more customization possibilities.
    Pod::UI.info "Adding Pod Licenses"
    excluded = ['BartyCrouch', 'SwiftLint', 'SimulatorStatusMagic']
    sandbox = installer.sandbox
    ios_target = installer.aggregate_targets.select { |target| target.label.include? 'iOS' }.first
    root_specs = ios_target.specs.map(&:root).uniq.reject { |spec| excluded.include?(spec.name) }

    pod_licenses = []
    root_specs.each do |spec|
        pod_root = sandbox.pod_dir(spec.name)
        platform = Pod::Platform.new(ios_target.platform.name)
        file_accessor = file_accessor(spec, platform, sandbox)
        license_text = license_text(spec, file_accessor)
        license_text = license_text.gsub(/(.)\n(.)/, '\1 \2')  # remove in text line breaks

        pod_license = {
            "Title" => spec.name,
            "Type" => "PSGroupSpecifier",
            "FooterText" => license_text,
        }
        pod_licenses << pod_license
    end

    metadata = {
        "PreferenceSpecifiers" => pod_licenses,
    }

    project = Xcodeproj::Project.open(ios_target.user_project_path)
    settings_bundle = settings_bundle_in_project(project)

    if settings_bundle == nil
        Pod::UI.warn "Could not find a Settings.bundle to add the Pod Settings Plist to."
    else
        settings_plist_path = settings_bundle + "/PodLicenses.plist"
        Xcodeproj::Plist.write_to_path(metadata, settings_plist_path)
        Pod::UI.info "Added Pod licenses to Settings.bundle for iOS"
    end
end


##########
# Helper methods for plist operations
##########

def file_accessor(spec, platform, sandbox)
    pod_root = sandbox.pod_dir(spec.name)
    if pod_root.exist?
        path_list = Pod::Sandbox::PathList.new(pod_root)
        Pod::Sandbox::FileAccessor.new(path_list, spec.consumer(platform))
    end
end

# Returns the text of the license for the given spec.
#
# @param  [Specification] spec
#         the specification for which license is needed.
#
# @return [String] The text of the license.
# @return [Nil] If not license text could be found.
#
def license_text(spec, file_accessor)
    return nil unless spec.license
    text = spec.license[:text]
    unless text
        if file_accessor
            if license_file = file_accessor.license
                if license_file.exist?
                text = IO.read(license_file)
                else
                Pod::UI.warn "Unable to read the license file `#{license_file }` " \
                    "for the spec `#{spec}`"
                end
            end
        end
    end
    text
end

def settings_bundle_in_project(project)
    file = project.files.find { |f| f.path =~ /Settings\.bundle$/ }
    file.real_path.to_path unless file.nil?
end
