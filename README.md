## BMPlayer

![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)
![Swift 3.0](https://img.shields.io/badge/Swift-3.0-brightgreen.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![License](https://img.shields.io/cocoapods/l/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![Platform](https://img.shields.io/cocoapods/p/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![Weibo](https://img.shields.io/badge/%E5%BE%AE%E5%8D%9A-%40%E8%89%BE%E5%8A%9B%E4%BA%9A%E5%B0%94-yellow.svg?style=flat)](http://weibo.com/536445669)

A simple video player for iOS, based on AVPlayer, pure swift.

[中文说明](https://github.com/BrikerMan/BMPlayer/blob/master/README.zh.md)

## Features
- Support for horizontal and vertical play mode
- Support play with online URL and local file
- Adjust brightness by slide vertical at left side of screen
- Adjust volume by slide vertical at right side of screen
- Slide horizontal to fast forward and rewind
- Support multi-definition video
- Mirror mode, slow play mode

## Requirements
- iOS 8 +
- Xcode 8 
- Swift 3

## Installation
### CocoaPods

#### Swift3
Please make sure using the **cocoapods 1.1.0.rc.2**, update with `sudo gem install cocoapods --pre`.

```ruby
target 'ProjectName' do
    use_frameworks!
    pod 'BMPlayer'
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |configuration|
            configuration.build_settings['SWIFT_VERSION'] = "3.0"
            configuration.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
        end
    end
end
```

#### Swift 2.2 
```
use_frameworks!

pod 'BMPlayer', '~> 0.3.3'
```

### Carthage
Add `BMPlayer` in your Cartfile.
```
github "BrikerMan/BMPlayer"
```
Run carthage to build the framework and drag the built BMPlayer.framework into your Xcode project.
### Demo
run `pod install` at `Example` folder before run the demo.

## Usage （Support IB and code）

### Set status bar color

Please add the `View controller-based status bar appearance` field in info.plist and change it to NO

### IB usage
Direct drag IB to UIView, the aspect ratio for the 16:9 constraint (priority to 750, lower than the 1000 line), the code section only needs to achieve. See more detail on the demo.

```swift
import BMPlayer

player.playWithURL(URL(string: url)!)

player.backBlock = { [unowned self] in
    let _ = self.navigationController?.popViewController(animated: true)
}
```

### Code implementation by [SnapKit](https://github.com/SnapKit/SnapKit)

```swift
import BMPlayer

player = BMPlayer()
view.addSubview(player)
player.snp.makeConstraints { (make) in
    make.top.equalTo(self.view).offset(20)
    make.left.right.equalTo(self.view)
    // Note here, the aspect ratio 16:9 priority is lower than 1000 on the line, because the 4S iPhone aspect ratio is not 16:9
    make.height.equalTo(player.snp.width).multipliedBy(9.0/16.0).priority(750)
}
// Back button event
player.backBlock = { [unowned self] in
    let _ = self.navigationController?.popViewController(animated: true)
}
```

### Set video url

```swift
player.playWithURL(URL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")!, title: "风格互换：原来你我相爱")
```

### multi-definition video with cover

```swift
let resource0 = BMPlayerItemDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/14570071502774.mp4")!, definitionName: "HD")
let resource1 = BMPlayerItemDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457007294968_5824_854x480.mp4")!, definitionName: "SD")

let item = BMPlayerItem(title: "周末号外丨川普版权力的游戏",
                        resource: [resource0, resource1],
                        cover: "http://img.wdjimg.com/image/video/acdba01e52efe8082d7c33556cf61549_0_0.jpeg")
```

### Listening to player state changes
See more detail from the Example project
#### Block
```swift
//Listen to when the player is playing or stopped
player?.playStateDidChange = { (isPlaying: Bool) in
    print("playStateDidChange \(isPlaying)")
}

//Listen to when the play time changes
player?.playTimeDidChange = { (currentTime: TimeInterval, totalTime: TimeInterval) in
    print("playTimeDidChange currentTime: \(currentTime) totalTime: \(totalTime)")
}
```

#### Delegate
```swift
protocol BMPlayerDelegate {
    func bmPlayer(player: BMPlayer ,playerStateDidChange state: BMPlayerState) { }
    func bmPlayer(player: BMPlayer ,loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval)  { }
    func bmPlayer(player: BMPlayer ,playTimeDidChange currentTime : TimeInterval, totalTime: TimeInterval)  { }
    func bmPlayer(player: BMPlayer ,playerIsPlaying playing: Bool)  { }
}
```
## Customize player
Needs to change before the player alloc.

```swift
// should print log, default false
BMPlayerConf.allowLog = false
// should auto play, default true
BMPlayerConf.shouldAutoPlay = true
// main tint color, default whiteColor
BMPlayerConf.tintColor = UIColor.whiteColor()
// options to show header view (which include the back button, title and definition change button) , default .Always，options: .Always, .HorizantalOnly and .None
BMPlayerConf.topBarShowInCase = .Always
// show mirror mode, slow play mode button, default false
BMPlayerConf.slowAndMirror = true
// loader type, see detail：https://github.com/ninjaprox/NVActivityIndicatorView
BMPlayerConf.loaderType  = NVActivityIndicatorType.BallRotateChase
```

## Advanced
- [Customize control UI](https://eliyar.biz/custom-player-ui-with-bmplayer/)
- or Use the `BMPlayerLayer` with your own player control view~

## Demonstration
![gif](https://github.com/BrikerMan/resources/raw/master/BMPlayer/demo.gif)

## Reference:
This project heavily reference the Objective-C version of this project [ZFPlayer](https://github.com/renzifeng/ZFPlayer), thanks for the generous help of ZFPlayer's author.

## Contact me：
- Blog: https://eliyar.biz
- Email: eliyar917@gmail.com

## Contributors
- [Albert Young](https://github.com/cedared)
- [tooodooo](https://github.com/tooodooo)
- [Ben Bahrenburg](https://github.com/benbahrenburg)

You are welcome to fork and submit pull requests.

## License
BMPlayer is available under the MIT license. See the LICENSE file for more info.


