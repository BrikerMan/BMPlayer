Pod::Spec.new do |s|
  s.name             = "BMPlayer"
  s.version          = "0.7.1"
  s.summary          = "Video Player Using Swift, based on AVPlayer"

  s.description      = <<-DESC
                        Video Player Using Swift, based on AVPlayer, support for the horizontal screen, vertical screen, the upper and lower slide to adjust the volume, the screen brightness, or so slide to adjust the playback progress.
                        DESC

  s.homepage         = "https://github.com/BrikerMan/BMPlayer"

  s.license          = 'MIT'
  s.author           = { "Eliyar Eziz" => "eliyar917@gmail.com" }
  s.source           = { :git => "https://github.com/BrikerMan/BMPlayer.git", :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/536445669'

  s.ios.deployment_target = '8.0'
  s.platform     = :ios, '8.0'
  s.source_files = 'BMPlayer/Classes/**/*'
  s.resources    = "BMPlayer/**/*.xcassets"


  s.frameworks = 'UIKit', 'AVFoundation'
  
  s.dependency 'SnapKit', '~> 3.0'
  s.dependency 'NVActivityIndicatorView'
end
