## BMPlayer

![Swift](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![License](https://img.shields.io/cocoapods/l/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![Platform](https://img.shields.io/cocoapods/p/BMPlayer.svg?style=flat)](http://cocoapods.org/pods/BMPlayer)
[![Weibo](https://img.shields.io/badge/%E5%BE%AE%E5%8D%9A-%40%E8%89%BE%E5%8A%9B%E4%BA%9A%E5%B0%94-yellow.svg?style=flat)](http://weibo.com/536445669)

## 介绍
本项目是基于 AVPlayer 使用 Swift 封装的视频播放器，方便快速集成。

## 功能
- [x] 支持竖屏切换，支持自动旋转屏幕
- [x] 支持本地视频、网络视频播放
- [x] 右侧 1/2 位置上下滑动调节屏幕亮度（模拟器调不了亮度，请在真机调试）
- [x] 左侧 1/2 位置上下滑动调节音量（模拟器调不了音量，请在真机调试）
- [x] 左右滑动调节播放进度
- [x] 清晰度切换
- [x] 自定义播放速度
- [x] 自定义资源 HTTP Header
- [x] 易于定制控制 UI
- [x] 展示本地和在在线字幕文件
- [x] [Swift 4](https://developer.apple.com/swift/)

## 要求
- iOS 8 +
- Xcode 7.3
- Swift 2.2

## 安装
### CocoaPods

| Swift     | podfile                      |
| --------- | ---------------------------- |
| Swift 5.0 | `pod 'BMPlayer', '~> 1.3.0'` |
| Swift 4.2 | `pod 'BMPlayer', '~> 1.2.0'` |
| Swift 4.0 | `pod 'BMPlayer', '~> 1.0.0'` |
| Swift 3.0 | `pod 'BMPlayer', '~> 0.9.1'` |
| Swift 2.2 | `pod 'BMPlayer', '~> 0.3.3'` |

**To test the experimental caching support with [VIMediaCache](https://github.com/vitoziv/VIMediaCache), use**

```swift
pod 'BMPlayer/CacheSupport', :git => 'https://github.com/BrikerMan/BMPlayer.git'
```

### Carthage
安装好 Carthage 后，将下列内容加入你项目的 Cartfile:
```
github "BrikerMan/BMPlayer"
```
最后，在 general panel 里 的 "Embedded Binaries" 项下点击 "Add Other..." 按钮，BMPlayer.framework 已经躺在了 ./Carthage/Build/iOS 目录里。

### Demo
运行 Demo ，请下载后先在 Example 目录运行 `pod install`

## 使用 （支持IB和代码）

### 设置状态栏颜色
请在 info.plist 中增加 "View controller-based status bar appearance" 字段，并改为 NO

### IB用法
直接拖 UIView 到 IB 上，宽高比为约束为 16:9 (优先级改为 750，比 1000 低就行)，代码部分只需要实现。更多细节请看Demo。

```swift
import BMPlayer

player.playWithURL(URL(string: url)!)

player.backBlock = { [unowned self] (isFullScreen) in
    if isFullScreen == true { return }
    let _ = self.navigationController?.popViewController(animated: true)
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
player.backBlock = { [unowned self] (isFullScreen) in
    let _ = self.navigationController?.popViewController(animated: true)
}
```

### 设置普通视频

```swift
let asset = BMPlayerResource(url: URL(string: "http://baobab.wdjcdn.com/14525705791193.mp4")!,
                             name: "风格互换：原来你我相爱")
player.setVideo(resource: asset)
```

### 多清晰度，带封面视频

```swift
let res0 = BMPlayerResourceDefinition(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!,
                                      definition: "高清")
let res1 = BMPlayerResourceDefinition(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!,
                                      definition: "标清")
   
let asset = BMPlayerResource(name: "周末号外丨中国第一高楼",
                             definitions: [res0, res1],
                             cover: URL(string: "http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg"))

player.setVideo(resource: asset)
```
### 设置 HTTP header

```swift
let header = ["User-Agent":"BMPlayer"]
let options = ["AVURLAssetHTTPHeaderFieldsKey":header]
  
let definition = BMPlayerResourceDefinition(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!,
                                            definition: "高清",
                                            options: options)
  
let asset = BMPlayerResource(name: "Video Name",
                             definitions: [definition])
```

### 监听状态变化
具体用法请看 Example 项目
#### 闭包方式
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

#### 协议方式
```swift
protocol BMPlayerDelegate {
    func bmPlayer(player: BMPlayer ,playerStateDidChange state: BMPlayerState) { }
    func bmPlayer(player: BMPlayer ,loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval)  { }
    func bmPlayer(player: BMPlayer ,playTimeDidChange currentTime : TimeInterval, totalTime: TimeInterval)  { }
    func bmPlayer(player: BMPlayer ,playerIsPlaying playing: Bool)  { }
}
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
// 加载效果，更多请见：https://github.com/ninjaprox/NVActivityIndicatorView
BMPlayerConf.loaderType  = NVActivityIndicatorType.BallRotateChase
```

## 进阶用法
- 继承 `BMPlayerControlView` 来创建自定义控制UI，具体实现请参考 Example
- 或者使用 `BMPlayerLayer` 并且自己定制控制 UI 和逻辑。

## 效果
![gif](https://github.com/BrikerMan/resources/raw/master/BMPlayer/demo.gif)

## 参考：
本项目重度参考了 [ZFPlayer](https://github.com/renzifeng/ZFPlayer)，感谢 ZFPlayer 作者的支持和帮助。

## 联系我：
- 博客: https://eliyar.biz
- 邮箱: eliyar917@gmail.com

## 贡献者
- [Albert Young](https://github.com/cedared)
- [tooodooo](https://github.com/tooodooo)
- [Ben Bahrenburg](https://github.com/benbahrenburg)

欢迎提交 issue 和 PR，大门永远向所有人敞开。

## License
BMPlayer is available under the MIT license. See the LICENSE file for more info.


