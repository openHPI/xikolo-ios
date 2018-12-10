use_frameworks!
inhibit_all_warnings!

project 'xikolo-ios', 'openHPI-iOS-Debug' => :debug, 'openSAP-iOS-Debug' => :debug, 'openWHO-iOS-Debug' => :debug, 'moocHOUSE-iOS-Debug' => :debug

pod 'BartyCrouch', :git => 'https://github.com/Flinesoft/BartyCrouch.git', :tag => '3.13.0'
pod 'R.swift', '5.0.0.alpha.3'
pod 'SwiftLint', '~> 0.22'

def firebase_pods
    pod 'Firebase/Core'
    pod 'Fabric', '~> 1.9.0'
    pod 'Crashlytics', '~> 3.12.0'
end

target 'Common' do
    platform :ios, '10.0'
    pod 'BrightFutures', '~> 7.0'
    pod 'Down', '0.5.2'
    pod 'KeychainAccess', '~> 3.1'
    pod 'ReachabilitySwift', '~> 4.1'
    pod 'SDWebImage', '~> 4.2'
    pod 'SyncEngine', :path => './Frameworks/SyncEngine'
    pod 'HTMLStyler', :path => './Frameworks/HTMLStyler'
    pod 'XCGLogger', '~> 6.0'

    target 'Common-Tests' do
        inherit! :search_paths
    end
end

target 'iOS' do
    platform :ios, '10.0'
    firebase_pods
    pod 'BMPlayer', :git => 'https://github.com/openHPI/bmplayer.git', :commit => '3cf7dd96b031172f2290da09e8bffbc2a3bade4e'
    pod 'DZNEmptyDataSet', '~> 1.8'
    pod 'SimulatorStatusMagic', '~> 2.1', :configurations => ['openHPI-iOS-Debug', 'openSAP-iOS-Debug', 'openWHO-iOS-Debug', 'moocHOUSE-iOS-Debug']
end

post_install do |installer|
    Pod::UI.info "Installing BartyCrouch manually"
    system("make installables -C ./Pods/BartyCrouch >> /dev/null")
    system("cp -f /tmp/BartyCrouch.dst/usr/local/bin/bartycrouch ./Pods/BartyCrouch/bartycrouch")

    Pod::UI.info "Fix provisioning profile specifiers"
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
    end

    # This is highly inspired by cocoapods-acknowledgements (https://github.com/CocoaPods/cocoapods-acknowledgements)
    # but creates only one pod license file for iOS instead of one license file for each target
    # Additonally, it provides more customization possibilities.
    Pod::UI.info "Adding Pod Licenses"
    excluded = ['BartyCrouch', 'R.swift', 'R.swift.Library', 'SwiftLint', 'SimulatorStatusMagic', 'SyncEngine', 'HTMLStyler']
    sandbox = installer.sandbox
    common_target = installer.aggregate_targets.select { |target| target.label.include? 'Common' }.first
    ios_target = installer.aggregate_targets.select { |target| target.label.include? 'iOS' }.first
    all_specs = common_target.specs.map(&:root) + ios_target.specs.map(&:root)
    ios_specs = all_specs.uniq.sort_by { |spec| spec.name }.reject { |spec| excluded.include?(spec.name) }

    pod_licenses = []
    ios_specs.each do |spec|
        pod_root = sandbox.pod_dir(spec.name)
        platform = Pod::Platform.new(ios_target.platform.name)
        file_accessor = file_accessor(spec, platform, sandbox)
        license_text = get_license_text(spec, file_accessor)
        license_text = license_text.gsub(/(.)\n(.)/, '\1 \2') if license_text # remove in text line breaks

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
def get_license_text(spec, file_accessor)
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
