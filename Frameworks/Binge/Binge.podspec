Pod::Spec.new do |spec|
  spec.name         = 'Binge'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/openHPI/Binge'
  spec.authors      = { 'Max Bothe' => 'max.bothe@hpi.de' }
  spec.summary      = 'Alternative to AVPlayerViewController'
  spec.source       = { :git => 'https://github.com/openhPI/Binge.git', :tag => spec.version.to_s }
  spec.source_files = 'Binge/*.swift'
  spec.resources    = [
    'Binge/**/*.xcassets',
    'Binge/*.lproj/*.strings',
  ]
  spec.frameworks   = 'UIKit', 'AVFoundation'
  spec.platform     = :ios, '10.0'
  spec.swift_version = '4.2'
end
