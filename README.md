## BMPlayer

![Swift](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)
[![Build Status](https://travis-ci.org/BrikerMan/BMPlayer.svg?branch=master)](https://travis-ci.org/BrikerMan/BMPlayer)
[![Version](https://img.shields.io/cocoapods/v/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![License](https://img.shields.io/cocoapods/l/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![Platform](https://img.shields.io/cocoapods/p/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![Weibo](https://img.shields.io/badge/%E5%BE%AE%E5%8D%9A-%40%E8%89%BE%E5%8A%9B%E4%BA%9A%E5%B0%94-yellow.svg?style=flat)](http://weibo.com/536445669)

## 介绍
本项目是基于 AVPlayer 使用 Swift 封装的视频播放器，方便快速集成。

## 功能
- 支持横、竖屏切换，在全屏播放模式下还可以锁定屏幕方向
- 支持本地视频、网络视频播放
- 左侧 1/2 位置上下滑动调节屏幕亮度（模拟器调不了亮度，请在真机调试）
- 右侧 1/2 位置上下滑动调节音量（模拟器调不了音量，请在真机调试）
- 左右滑动调节播放进度
- 清晰度切换
- 镜像、慢放
- 支持自动旋转屏幕

## 要求
- iOS 8 +
- Xcode 7.3
- Swift 2.2

## 安装
### CocoaPods

```ruby
use_frameworks!

pod 'BMPlayer', '~> 0.2.0'
```

### Demo
运行 Demo ，请下载后先在 Example 目录运行 `pod install`

## 使用 （支持IB和代码）

### 设置状态栏颜色
请在 info.plist 中增加 "View controller-based status bar appearance" 字段，并改为 NO

### IB用法
直接拖 UIView 到 IB 上，宽高比为约束为 16:9 (优先级改为 750，比 1000 低就行)，代码部分只需要实现。更多细节请看Demo。

```swift
import BMPlayer

player.playWithURL(NSURL(string: url)!)

player.backBlock = { [unowned self] in
    self.navigationController?.popViewControllerAnimated(true)
}
```

### 代码布局（[SnapKit](https://github.com/SnapKit/SnapKit)）

```swift
import BMPlayer

player = BMPlayer()
view.addSubview(player)
player.snp_makeConstraints { (make) in
    make.top.equalTo(self.view).offset(20)
    make.left.right.equalTo(self.view)
    // 注意此处，宽高比 16:9 优先级比 1000 低就行，在因为 iPhone 4S 宽高比不是 16：9
        make.height.equalTo(player.snp_width).multipliedBy(9.0/16.0).priority(750)
}
player.backBlock = { [unowned self] in
    self.navigationController?.popViewControllerAnimated(true)
}
```

### 设置普通视频

```swift
// 若title为""，则不显示
player.playWithURL(NSURL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")!, title: "风格互换：原来你我相爱")
```

### 多清晰度，带封面视频

```swift
let resource0 = BMPlayerItemDefinitionItem(url: NSURL(string: "http://baobab.wdjcdn.com/14570071502774.mp4")!, definitionName: "高清")
let resource1 = BMPlayerItemDefinitionItem(url: NSURL(string: "http://baobab.wdjcdn.com/1457007294968_5824_854x480.mp4")!, definitionName: "标清")

let item    = BMPlayerItem(title: "周末号外丨川普版权力的游戏",
resource: [resource0, resource1],
cover: "http://img.wdjimg.com/image/video/acdba01e52efe8082d7c33556cf61549_0_0.jpeg")
```

## 播放器自定义属性
需要在创建播放器前设定

```swift
// 是否打印日志，默认false
BMPlayerConf.allowLog = false
// 是否自动播放，默认true
BMPlayerConf.shouldAutoPlay = true
// 主体颜色，默认白色
BMPlayerConf.tintColor = UIColor.whiteColor()
// 顶部返回和标题显示选项，默认.Always，可选.HorizantalOnly、.None
BMPlayerConf.topBarShowInCase = .Always
// 显示慢放和镜像按钮
BMPlayerConf.slowAndMirror = true
// 加载效果，更多请见：https://github.com/ninjaprox/NVActivityIndicatorView
BMPlayerConf.loaderType  = NVActivityIndicatorType.BallRotateChase
```

## 效果
![gif](https://github.com/BrikerMan/resources/raw/master/BMPlayer/demo.gif)

## 参考：
本项目重度参考了 [ZFPlayer](https://github.com/renzifeng/ZFPlayer)，感谢 ZFPlayer 作者的支持和帮助。

## 联系我：
- 博客: https://eliyar.biz
- 邮箱: eliyar917@gmail.com

## 贡献者
- [Albert Young](https://github.com/cedared)

## License
BMPlayer is available under the MIT license. See the LICENSE file for more info.
