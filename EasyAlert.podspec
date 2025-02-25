#
# Be sure to run `pod lib lint EasyAlert.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EasyAlert'
  s.version          = '0.3.9'
  s.summary          = 'A short description of EasyAlert.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zhwayne/EasyAlert'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iya' => 'mrzhwayne@163.com' }
  s.source           = { :git => 'https://github.com/zhwayne/EasyAlert.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.swift_version = '5.8'
  s.source_files = 'Sources/**/*'
  
  s.subspec 'Lite' do |a|
    a.source_files = 'Sources/Lite/**/*'
    # a.dependency 'SnapKit'
  end
  
  # s.resource_bundles = {
  #   'EasyAlert' => ['EasyAlert/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
