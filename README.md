## BMPlayer

[![Build Status](https://travis-ci.org/BrikerMan/BMPlayer.svg?branch=master)](https://travis-ci.org/BrikerMan/BMPlayer)
[![Version](https://img.shields.io/cocoapods/v/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![License](https://img.shields.io/cocoapods/l/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![Platform](https://img.shields.io/cocoapods/p/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)

**正在开发**

## 介绍
本项目是基于 AVPlayer 使用 Swift 封装的视频播放器，方便快速集成。目前处于开发阶段，功能将持续完善。

## 功能
- 支持横、竖屏切换，在全屏播放模式下还可以锁定屏幕方向
- 支持本地视频、网络视频播放
- 左侧 1/2 位置上下滑动调节屏幕亮度（模拟器调不了亮度，请在真机调试）
- 右侧 1/2 位置上下滑动调节音量（模拟器调不了音量，请在真机调试）
- 左右滑动调节播放进度
- 切换视频分辨率

## 要求
- iOS 8 +
- Xcode 7.3
- Swift 2.2

## 安装
### CocoaPods

```ruby
use_frameworks!

pod 'BMPlayer', :git => 'https://github.com/BrikerMan/BMPlayer.git'
```

### Demo
运行 Demo ，请下载后先在 Example 目录运行 `pod install`

## 使用 （支持IB和代码）

### 设置状态栏颜色
请在 info.plist 中增加 "View controller-based status bar appearance" 字段，并改为 NO

### IB用法
直接拖 UIView 到 IB 上，宽高比为约束为 16:9 (优先级改为 750，比 1000 低就行)，代码部分只需要实现
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

player.playWithURL(NSURL(string: url)!)

player.backBlock = { [unowned self] in
    self.navigationController?.popViewControllerAnimated(true)
}
```

## 参考：
本项目重度参考了 [ZFPlayer](https://github.com/renzifeng/ZFPlayer)，感谢 ZFPlayer 作者的支持和帮助。

## 联系我：
- 博客: https://eliyar.biz
- 邮箱: eliyar917@gmail.com

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 8 +
- Xcode 7.3
- Swift 2.2

## Installation

BMPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!

pod 'BMPlayer', :git => 'https://github.com/BrikerMan/BMPlayer.git'
```

## License

BMPlayer is available under the MIT license. See the LICENSE file for more info.
