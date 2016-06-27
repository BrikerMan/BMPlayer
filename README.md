## BMPlayer

![Swift](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)
[![Build Status](https://travis-ci.org/BrikerMan/BMPlayer.svg?branch=master)](https://travis-ci.org/BrikerMan/BMPlayer)
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
- Xcode 7.3
- Swift 2.2

## Installation
### CocoaPods

```ruby
use_frameworks!

pod 'BMPlayer', '~> 0.2.0'
```

### Demo
run `pod install` at `Example` folder before run the demo.

## Usage （Support IB and code）

### Set status bar color

Please add the `View controller-based status bar appearance` field in info.plist and change it to NO

### IB usage
Direct drag IB to UIView, the aspect ratio for the 16:9 constraint (priority to 750, lower than the 1000 line), the code section only needs to achieve. See more detail on the demo.

```swift
import BMPlayer

player.playWithURL(NSURL(string: url)!)

player.backBlock = { [unowned self] in
    self.navigationController?.popViewControllerAnimated(true)
}
```

### Code implementation by [SnapKit](https://github.com/SnapKit/SnapKit)

```swift
import BMPlayer

player = BMPlayer()
view.addSubview(player)
player.snp_makeConstraints { (make) in
    make.top.equalTo(self.view).offset(20)
    make.left.right.equalTo(self.view)
        // Note here, the aspect ratio 16:9 priority is lower than 1000 on the line, because the 4S iPhone aspect ratio is not 16:9
        make.height.equalTo(player.snp_width).multipliedBy(9.0/16.0).priority(750)
}
// Back button event
player.backBlock = { [unowned self] in
    self.navigationController?.popViewControllerAnimated(true)
}
```

### Set video url

```swift
player.playWithURL(NSURL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")!, title: "风格互换：原来你我相爱")
```

### multi-definition video with cover

```swift
let resource0 = BMPlayerItemDefinitionItem(url: NSURL(string: "http://baobab.wdjcdn.com/14570071502774.mp4")!, definitionName: "HD")
let resource1 = BMPlayerItemDefinitionItem(url: NSURL(string: "http://baobab.wdjcdn.com/1457007294968_5824_854x480.mp4")!, definitionName: "SD")

let item    = BMPlayerItem(title: "周末号外丨川普版权力的游戏",
resource: [resource0, resource1],
cover: "http://img.wdjimg.com/image/video/acdba01e52efe8082d7c33556cf61549_0_0.jpeg")
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

## Demonstration
![gif](https://github.com/BrikerMan/resources/raw/master/BMPlayer/demo.gif)

## Reference:
This project heavily reference the Objective-C version of this project [ZFPlayer](https://github.com/renzifeng/ZFPlayer), thanks for the generous help of ZFPlayer's author.

## Contact me：
- Blog: https://eliyar.biz
- Email: eliyar917@gmail.com

## Contributors
- [Albert Young](https://github.com/cedared)

## License
BMPlayer is available under the MIT license. See the LICENSE file for more info.
