#!/usr/bin/env ruby

require 'Xcodeproj'

excluded_dependencies = ['R.swift']

project_dir = ENV['PROJECT_DIR']
build_dir = ENV['BUILD_DIR']
project_file_path = ENV['PROJECT_FILE_PATH']

def licenses_plist_path(project_dir)
    File.join(project_dir, 'iOS', 'Settings.bundle', 'Licenses.plist')
end

def license_data(packages_checkouts_dir, dependency_name)
    dir = File.join(packages_checkouts_dir, dependency_name)
    license_text = license_from_dir(dir)

    return unless license_text

    {
        "Title" => dependency_name,
        "Type" => "PSGroupSpecifier",
        "FooterText" => license_text,
    }
end

def license_from_dir(directory)
    license_file_path = Dir.entries(directory)
                            .map { |file_name| File.join(directory, file_name) }
                            .select { |file_path| license_file?(file_path) }
                            .first
    license_text = File.read(license_file_path, :encoding => 'UTF-8') if license_file_path
    license_text.gsub(/(.)\n(.)/, '\1 \2') if license_text # remove line breaks with paragraphs
end

def license_file?(path)
    name = File.basename(path, '.*').downcase
    name.start_with?('license') or name.start_with?('licence')
end

# Determine directory of dependency checkouts
derived_data_dir = File.dirname(File.dirname(build_dir))
packages_checkouts_dir = File.join(derived_data_dir, 'SourcePackages', 'checkouts')

# Get dependencies (package references) from Xcode project
project = Xcodeproj::Project.open(project_file_path)
package_references = project.root_object.package_references
dependency_names = package_references
                        .map { |ref| File.basename(ref.display_name, ".*") }
                        .sort_by { |name| name.downcase }
                        .reject { |name| excluded_dependencies.include?(name) }

# Get license data for dependencies
licenses = dependency_names.map { |dependency_name| license_data(packages_checkouts_dir, dependency_name) }.compact

# Write license data to plist file
metadata = {"PreferenceSpecifiers" => licenses}
Xcodeproj::Plist.write_to_path(metadata, licenses_plist_path(project_dir))
