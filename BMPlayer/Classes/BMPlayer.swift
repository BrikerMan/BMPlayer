//
//  BMPlayer.swift
//  Pods
//
//  Created by BrikerMan on 16/4/28.
//
//

import UIKit
import SnapKit
import MediaPlayer

enum BMPlayerState {
    case NotSetURL      // 未设置URL
    case ReadyToPlay    // 可以播放
    case Buffering      // 缓冲中
    case BufferFinished // 缓冲完毕
    case PlayedToTheEnd // 播放结束
    case Error          // 出现错误
}

/// 枚举值，包含水平移动方向和垂直移动方向
enum BMPanDirection: Int {
    case Horizontal = 0
    case Vertical   = 1
}

enum BMPlayerItemType {
    case URL
    case BMPlayerItem
}

public class BMPlayer: UIView {
    
    public var backBlock:(() -> Void)?
    
    var videoItem: BMPlayerItem!
    
    var currentDefinition = 0
    
    var playerLayer: BMPlayerLayerView?
    
    var controlView: BMPlayerControlView!
    
    var playerItemType = BMPlayerItemType.URL
    
    var videoItemURL: NSURL!
    
    var videoTitle = ""
    
    var isFullScreen:Bool {
        get {
            return UIApplication.sharedApplication().statusBarOrientation.isLandscape
        }
    }
    
    /// 滑动方向
    private var panDirection = BMPanDirection.Horizontal
    /// 音量滑竿
    private var volumeViewSlider: UISlider!
    
    private let BMPlayerAnimationTimeInterval:Double                = 4.0
    private let BMPlayerControlBarAutoFadeOutTimeInterval:Double    = 0.5
    
    /// 用来保存时间状态
    private var sumTime         : NSTimeInterval = 0
    private var totalDuration   : NSTimeInterval = 0
    private var currentPosition : NSTimeInterval = 0
    private var shouldSeekTo    : NSTimeInterval = 0
    
    private var isURLSet        = false
    private var isSliderSliding = false
    private var isPauseByUser   = false
    private var isVolume        = false
    private var isMaskShowing   = false
    private var isSlowed        = false
    private var isMirrored      = false
    
    
    // MARK: - Public functions
    /**
     直接使用URL播放
     
     - parameter url:   视频URL
     - parameter title: 视频标题
     */
    public func playWithURL(url: NSURL, title: String = "") {
        playerItemType              = BMPlayerItemType.URL
        videoItemURL                = url
        controlView.titleLabel.text = title
        
        if BMPlayerConf.shouldAutoPlay {
            playerLayer?.videoURL   = videoItemURL
            isURLSet                = true
        } else {
            controlView.hideLoader()
        }
    }
    
    /**
     播放可切换清晰度的视频
     
     - parameter items: 清晰度列表
     - parameter title: 视频标题
     - parameter definitionIndex: 起始清晰度
     */
    public func playWithPlayerItem(item:BMPlayerItem, definitionIndex: Int = 0) {
        playerItemType              = BMPlayerItemType.BMPlayerItem
        videoItem                   = item
        controlView.titleLabel.text = item.title
        currentDefinition           = definitionIndex
        controlView.prepareChooseDefinitionView(item.resource, index: definitionIndex)
        
        if BMPlayerConf.shouldAutoPlay {
            playerLayer?.videoURL   = videoItem.resource[currentDefinition].playURL
            isURLSet                = true
        } else {
            controlView.showCoverWithLink(item.cover)
        }
    }
    
    /**
     使用自动播放，参照pause函数
     */
    public func autoPlay() {
        if !isPauseByUser && isURLSet {
            self.play()
        }
    }
    
    /**
     手动播放
     */
    public func play() {
        if !isURLSet {
            if playerItemType == BMPlayerItemType.BMPlayerItem {
                playerLayer?.videoURL       = videoItem.resource[currentDefinition].playURL
            } else {
                playerLayer?.videoURL       = videoItemURL
            }
            controlView.hideImageView()
            isURLSet                = true
        }
        playerLayer?.play()
        isPauseByUser = false
    }
    
    /**
     暂停
     
     - parameter allowAutoPlay: 是否允许自动播放，默认不允许，若允许则在调用autoPlay的情况下开始播放。否则autoPlay不会进行播放。
     */
    public func pause(allowAutoPlay allow: Bool = false) {
        playerLayer?.pause()
        isPauseByUser = !allow
    }
    
    /**
     开始自动隐藏UI倒计时
     */
    public func autoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideControlViewAnimated), object: nil)
        self.performSelector(#selector(hideControlViewAnimated), withObject: nil, afterDelay: BMPlayerAnimationTimeInterval)
    }
    
    /**
     取消UI自动隐藏
     */
    public func cancelAutoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    /**
     旋转屏幕时更新UI
     */
    public func updateUI(isFullScreen: Bool) {
        if isFullScreen {
            controlView.isFullScreen = true
        }else {
            controlView.isFullScreen = false
        }
        controlView.updateUI()
    }
    
    /**
     准备销毁，适用于手动隐藏等场景
     */
    public func prepareToDealloc() {
        playerLayer?.prepareToDeinit()
    }
    
    
    // MARK: - Action Response
    private func playStateDidChanged() {
        if isSliderSliding { return }
        if let player = playerLayer {
            if player.isPlaying {
                autoFadeOutControlBar()
                controlView.playButton.selected = true
            } else {
                controlView.playButton.selected = false
            }
        }
    }
    
    
    @objc private func hideControlViewAnimated() {
        UIView.animateWithDuration(BMPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.hidePlayerIcons()
            if self.isFullScreen {
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            }
        }) { (_) in
            self.isMaskShowing = false
        }
    }
    
    @objc private func showControlViewAnimated() {
        UIView.animateWithDuration(BMPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.showPlayerIcons()
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        }) { (_) in
            self.autoFadeOutControlBar()
            self.isMaskShowing = true
        }
    }
    
    @objc private func tapGestureTapped(sender: UIGestureRecognizer) {
        if isMaskShowing {
            hideControlViewAnimated()
            autoFadeOutControlBar()
        } else {
            showControlViewAnimated()
        }
    }
    
    @objc private func panDirection(pan: UIPanGestureRecognizer) {
        // 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.locationInView(self)
        
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint = pan.velocityInView(self)
        
        // 判断是垂直移动还是水平移动
        switch pan.state {
        case UIGestureRecognizerState.Began:
            // 使用绝对值来判断移动的方向
            
            let x = fabs(velocityPoint.x)
            let y = fabs(velocityPoint.y)
            
            if x > y {
                self.panDirection = BMPanDirection.Horizontal
                
                // 给sumTime初值
                if let player = playerLayer?.player {
                    let time = player.currentTime()
                    self.sumTime = NSTimeInterval(time.value) / NSTimeInterval(time.timescale)
                }
                
            } else {
                self.panDirection = BMPanDirection.Vertical
                if locationPoint.x > self.bounds.size.width / 2 {
                    self.isVolume = true
                } else {
                    self.isVolume = false
                }
            }
            
        case UIGestureRecognizerState.Changed:
            cancelAutoFadeOutControlBar()
            switch self.panDirection {
            case BMPanDirection.Horizontal:
                self.horizontalMoved(velocityPoint.x)
            case BMPanDirection.Vertical:
                self.verticalMoved(velocityPoint.y)
            }
        case UIGestureRecognizerState.Ended:
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
            case BMPanDirection.Horizontal:
                controlView.hideSeekToView()
                isSliderSliding = false
                playerLayer?.seekToTime(Int(self.sumTime), completionHandler: nil)
                // 把sumTime滞空，不然会越加越多
                self.sumTime = 0.0
                
            //                controlView.showLoader()
            case BMPanDirection.Vertical:
                self.isVolume = false
            }
        default:
            break
        }
    }
    
    private func verticalMoved(value: CGFloat) {
        self.isVolume ? (self.volumeViewSlider.value -= Float(value / 10000)) : (UIScreen.mainScreen().brightness -= value / 10000)
    }
    
    private func horizontalMoved(value: CGFloat) {
        isSliderSliding = true
        if let playerItem = playerLayer?.playerItem {
            // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
            self.sumTime = self.sumTime + NSTimeInterval(value) / 100.0 * (NSTimeInterval(self.totalDuration)/400)
            
            let totalTime       = playerItem.duration
            
            // 防止出现NAN
            if totalTime.timescale == 0 { return }
            
            let totalDuration   = NSTimeInterval(totalTime.value) / NSTimeInterval(totalTime.timescale)
            if (self.sumTime > totalDuration) { self.sumTime = totalDuration}
            if (self.sumTime < 0){ self.sumTime = 0}
            
            let targetTime      = formatSecondsToString(sumTime)
            
            controlView.timeSlider.value      = Float(sumTime / totalDuration)
            controlView.currentTimeLabel.text = targetTime
            controlView.showSeekToView(targetTime, isAdd: value > 0)
            
        }
    }
    
    @objc private func progressSliderTouchBegan(sender: UISlider)  {
        playerLayer?.onTimeSliderBegan()
        isSliderSliding = true
    }
    
    @objc private func progressSliderValueChanged(sender: UISlider)  {
        self.pause(allowAutoPlay: true)
        cancelAutoFadeOutControlBar()
    }
    
    @objc private func progressSliderTouchEnded(sender: UISlider)  {
        isSliderSliding = false
        autoFadeOutControlBar()
        let target = self.totalDuration * Double(sender.value)
        playerLayer?.seekToTime(Int(target), completionHandler: nil)
        autoPlay()
    }
    
    @objc private func backButtonPressed(button: UIButton) {
        if isFullScreen {
            fullScreenButtonPressed(nil)
        } else {
            playerLayer?.prepareToDeinit()
            backBlock?()
        }
    }
    
    @objc private func slowButtonPressed(button: UIButton) {
        autoFadeOutControlBar()
        if isSlowed {
            self.playerLayer?.player?.rate = 1.0
            self.isSlowed = false
            self.controlView.slowButton.setTitle("慢放", forState: .Normal)
        } else {
            self.playerLayer?.player?.rate = 0.5
            self.isSlowed = true
            self.controlView.slowButton.setTitle("正常", forState: .Normal)
        }
    }
    
    @objc private func mirrorButtonPressed(button: UIButton) {
        autoFadeOutControlBar()
        if isMirrored {
            self.playerLayer?.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.isMirrored = false
            self.controlView.mirrorButton.setTitle("镜像", forState: .Normal)
        } else {
            self.playerLayer?.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            self.isMirrored = true
            self.controlView.slowButton.setTitle("正常", forState: .Normal)
        }    }
    
    @objc private func replayButtonPressed(button: UIButton) {
        controlView.centerButton.hidden = true
        playerLayer?.seekToTime(0, completionHandler: {
            
        })
        self.play()
    }
    
    @objc private func playButtonPressed(button: UIButton) {
        if button.selected {
            self.pause()
        } else {
            self.play()
        }
    }
    
    @objc private func onOrientationChanged() {
        self.updateUI(isFullScreen)
    }
    
    @objc private func fullScreenButtonPressed(button: UIButton?) {
        if !isURLSet {
            //            self.play()
        }
        controlView.isFullScreen = !self.isFullScreen
        if isFullScreen {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.Portrait, animated: false)
        } else {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.LandscapeRight, animated: false)
        }
    }
    
    // MARK: - 生命周期
    deinit {
        playerLayer?.pause()
        playerLayer?.prepareToDeinit()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initUIData()
        configureVolume()
        preparePlayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        initUIData()
        configureVolume()
        preparePlayer()
    }
    
    private func formatSecondsToString(secounds: NSTimeInterval) -> String {
        let Min = Int(secounds / 60)
        let Sec = Int(secounds % 60)
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    // MARK: - 初始化
    private func initUI() {
        self.backgroundColor = UIColor.blackColor()
        controlView =  BMPlayerControlView()
        addSubview(controlView)
        controlView.updateUI()
        controlView.delegate = self
        controlView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureTapped(_:)))
        self.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panDirection(_:)))
        //        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
    
    private func initUIData() {
        controlView.playButton.addTarget(self, action: #selector(self.playButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.fullScreenButton.addTarget(self, action: #selector(self.fullScreenButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.backButton.addTarget(self, action: #selector(self.backButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.centerButton.addTarget(self, action: #selector(self.replayButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), forControlEvents: UIControlEvents.TouchDown)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), forControlEvents: [UIControlEvents.TouchUpInside,UIControlEvents.TouchCancel, UIControlEvents.TouchUpOutside])
        controlView.slowButton.addTarget(self, action: #selector(slowButtonPressed(_:)), forControlEvents: .TouchUpInside)
        controlView.mirrorButton.addTarget(self, action: #selector(mirrorButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onOrientationChanged), name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }
    
    private func configureVolume() {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                self.volumeViewSlider = slider
            }
        }
    }
    
    private func preparePlayer() {
        playerLayer = BMPlayerLayerView()
        insertSubview(playerLayer!, atIndex: 0)
        playerLayer!.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        playerLayer!.delegate = self
        controlView.showLoader()
        self.layoutIfNeeded()
    }
}

extension BMPlayer: BMPlayerLayerViewDelegate {
    func bmPlayer(player player: BMPlayerLayerView, playerIsPlaying playing: Bool) {
        playStateDidChanged()
    }
    
    func bmPlayer(player player: BMPlayerLayerView ,loadedTimeDidChange  loadedDuration: NSTimeInterval , totalDuration: NSTimeInterval) {
        self.totalDuration = totalDuration
        BMPlayerManager.shared.log("loadedTimeDidChange - \(loadedDuration) - \(totalDuration)")
        controlView.progressView.setProgress(Float(loadedDuration)/Float(totalDuration), animated: true)
    }
    
    func bmPlayer(player player: BMPlayerLayerView, playerStateDidChange state: BMPlayerState) {
        BMPlayerManager.shared.log("playerStateDidChange - \(state)")
        switch state {
        case BMPlayerState.ReadyToPlay:
            if shouldSeekTo != 0 {
                playerLayer?.seekToTime(Int(shouldSeekTo), completionHandler: {
                    
                })
                shouldSeekTo = 0
            }
        case BMPlayerState.Buffering:
            cancelAutoFadeOutControlBar()
            controlView.showLoader()
            playStateDidChanged()
        case BMPlayerState.BufferFinished:
            controlView.hideLoader()
            playStateDidChanged()
            autoPlay()
        case BMPlayerState.PlayedToTheEnd:
            self.pause()
            controlView.showVideoEndedView()
        default:
            break
        }
    }
    
    func bmPlayer(player player: BMPlayerLayerView, playTimeDidChange currentTime: NSTimeInterval, totalTime: NSTimeInterval) {
        self.currentPosition = currentTime
        BMPlayerManager.shared.log("playTimeDidChange - \(currentTime) - \(totalTime)")
        totalDuration = totalTime
        if isSliderSliding {
            return
        }
        controlView.currentTimeLabel.text = formatSecondsToString(currentTime)
        controlView.totalTimeLabel.text = formatSecondsToString(totalTime)
        
        controlView.timeSlider.value    = Float(currentTime) / Float(totalTime)
    }
}

extension BMPlayer: BMPlayerControlViewDelegate {
    func controlViewDidChooseDefition(index: Int) {
        shouldSeekTo                = currentPosition
        playerLayer?.resetPlayer()
        playerLayer?.videoURL       = videoItem.resource[index].playURL
        currentDefinition           = index
    }
}