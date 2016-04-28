#
# Be sure to run `pod lib lint BMPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BMPlayer"
  s.version          = "0.1.0"
  s.summary          = "Video Player Using Swift, based on AVPlayer"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "Video Player Using Swift, based on AVPlayer, support for the horizontal screen, vertical screen, the upper and lower slide to adjust the volume, the screen brightness, or so slide to adjust the playback progress."

  s.homepage         = "https://github.com/BrikerMan/BMPlayer"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Eliyar Eziz" => "eliyar917@gmail.com" }
  s.source           = { :git => "https://github.com/BrikerMan/BMPlayer.git", :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/536445669'

  s.ios.deployment_target = '8.0'

  s.source_files = 'BMPlayer/Classes/**/*'
  s.resource_bundles = {
    'BMPlayer' => ['BMPlayer/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
