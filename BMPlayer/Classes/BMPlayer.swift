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
    //    case MediaInfoReady // 获取媒体信息
    case Buffering      // 缓冲中
    case BufferFinished // 播放中
    case ReadyToPlay    // 播放中
    case Playing        // 播放中
    case Stopped        // 停止播放
    case Pause          // 暂停播放
    case PlayedToTheEnd //
    case Error
}

/// 枚举值，包含水平移动方向和垂直移动方向
enum BMPanDirection: Int {
    case Horizontal = 0
    case Vertical   = 1
}

public class BMPlayer: UIView {
    
    public var backBlock:(() -> Void)?
    
    var playerLayer: BMPlayerLayerView?
    
    var controlView: BMPlayerControlView!
    
    var customControlView: BMPlayerControlView?
    /// 是否显示controlView
    private var isMaskShowing = false
    
    private var isFullScreen  = false
    /// 用来保存快进的总时长
    private var sumTime     : Float!
    /// 滑动方向
    private var panDirection = BMPanDirection.Horizontal
    /// 是否是音量
    private var isVolume = false
    /// 音量滑竿
    private var volumeViewSlider: UISlider!
    
    private let BMPlayerAnimationTimeInterval:Double                = 4.0
    private let BMPlayerControlBarAutoFadeOutTimeInterval:Double    = 0.5
    
    private var totalTime = 1
    
    private var isSliderSliding = false
    
    // MARK: - Public functions
    public func playWithURL(url: NSURL) {
        playerLayer = BMPlayerLayerView()
        insertSubview(playerLayer!, atIndex: 0)
        playerLayer!.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        playerLayer!.delegate = self
        playerLayer!.videoURL = url
        controlView.loadIndector.startAnimating()
        self.layoutIfNeeded()
    }
    
    public func play() {
        playerLayer?.play()
    }
    
    public func pause() {
        playerLayer?.pause()
    }
    
    public func autoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideControlViewAnimated), object: nil)
        self.performSelector(#selector(hideControlViewAnimated), withObject: nil, afterDelay: BMPlayerAnimationTimeInterval)
    }
    
    public func cancelAutoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    // MARK: - Action Response
    @objc private func hideControlViewAnimated() {
        UIView.animateWithDuration(BMPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.hidePlayerIcons()
            //            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            
        }) { (_) in
            self.isMaskShowing = false
        }
    }
    
    @objc private func showControlViewAnimated() {
        UIView.animateWithDuration(BMPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.showPlayerIcons()
            //            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        }) { (_) in
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
                self.controlView.centerLabel.hidden = false
                self.panDirection = BMPanDirection.Horizontal
                
                // 给sumTime初值
                if let player = playerLayer?.player {
                    let time = player.currentTime()
                    self.sumTime = Float(time.value) / Float(time.timescale)
                }
                
                playerLayer?.player?.pause()
                playerLayer?.timer?.fireDate = NSDate.distantFuture()
            } else {
                self.panDirection = BMPanDirection.Vertical
                if locationPoint.x > self.bounds.size.width / 2 {
                    self.isVolume = true
                } else {
                    self.isVolume = false
                }
            }
            
        case UIGestureRecognizerState.Changed:
            switch self.panDirection {
            case BMPanDirection.Horizontal:
                self.horizontalMoved(velocityPoint.x)
                print(velocityPoint.x)
            case BMPanDirection.Vertical:
                self.verticalMoved(velocityPoint.y)
                print(velocityPoint.y)
            }
        case UIGestureRecognizerState.Ended:
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
            case BMPanDirection.Horizontal:
                playerLayer?.player?.play()
                playerLayer?.timer?.fireDate = NSDate()
                
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * 1.0 ))
                
                dispatch_after(popTime, dispatch_get_main_queue()) {
                    // 隐藏视图
                    self.controlView.centerLabel.hidden = true
                }
                
                playerLayer?.isPauseByUser = false
                playerLayer?.seekToTime(Int(self.sumTime), completionHandler: nil)
                // 把sumTime滞空，不然会越加越多
                self.sumTime = 0.0
                
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
        // 快进快退的方法
        var style = ""
        if value < 0 { style = "<<" }
        if value > 0 { style = ">>" }
        isSliderSliding = true
        // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
        self.sumTime = self.sumTime + Float(value) / 100.0 * (Float(totalTime)/400)
        
        if let playerItem = playerLayer?.playerItem {
            let totalTime       = playerItem.duration
            
            // 防止出现NAN
            if totalTime.timescale == 0 { return }
            
            let totalDuration   = Float(totalTime.value) / Float(totalTime.timescale)
            if (self.sumTime > totalDuration) { self.sumTime = totalDuration}
            if (self.sumTime < 0){ self.sumTime = 0}
            
            let nowTime      = formatSecondsToString(Int(sumTime))
            let durationTime = formatSecondsToString(Int(totalDuration))
            
            controlView.timeSlider.value    = Float(Int(sumTime)) / Float(self.totalTime)
            controlView.currentTimeLabel.text = formatSecondsToString(Int(sumTime))
            self.controlView.centerLabel.text = "\(style) \(nowTime) / \(durationTime)"
        }
    }
    
    @objc private func progressSliderTouchBegan(sender: UISlider)  {
        playerLayer?.onTimeSliderBegan()
        cancelAutoFadeOutControlBar()
        isSliderSliding = true
    }
    
    @objc private func progressSliderValueChanged(sender: UISlider)  {
        self.pause()
    }
    
    @objc private func progressSliderTouchEnded(sender: UISlider)  {
        controlView.loadIndector.startAnimating()
        autoFadeOutControlBar()
        playerLayer?.onSliderTouchEnd(withValue: sender.value)
    }
    
    @objc private func backButtonPressed(button: UIButton) {
        if isFullScreen {
            fullScreenButtonPressed(nil)
        } else {
            playerLayer?.prepareToDeinit()
            backBlock?()
        }
    }
    
    @objc private func playButtonPressed(button: UIButton) {
        if button.selected {
            self.pause()
        } else {
            self.play()
        }
    }
    
    @objc private func fullScreenButtonPressed(button: UIButton?) {
        if isFullScreen {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.Portrait, animated: false)
        } else {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.LandscapeRight, animated: false)
        }
        isFullScreen = !isFullScreen
    }
    
    // MARK: - 生命周期
    deinit {
        playerLayer?.pause()
        playerLayer?.prepareToDeinit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initUIData()
        configureVolume()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        initUIData()
        configureVolume()
    }
    
    private func formatSecondsToString(secounds: Int) -> String {
        let Min = secounds / 60
        let Sec = secounds % 60
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    // MARK: - 初始化
    private func initUI() {
        self.backgroundColor = UIColor.blackColor()
        if let customControlView = customControlView {
            controlView =  customControlView
        } else {
            controlView =  BMPlayerControlView()
        }
        
        addSubview(controlView)
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
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), forControlEvents: UIControlEvents.TouchDown)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), forControlEvents: [UIControlEvents.TouchUpInside,UIControlEvents.TouchCancel, UIControlEvents.TouchUpOutside])
    }
    
    private func configureVolume() {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                self.volumeViewSlider = slider
            }
        }
    }
}

extension BMPlayer: BMPlayerLayerViewDelegate {
    
    func bmPlayer(player player: BMPlayerLayerView ,loadedTimeDidChange  loadedDuration: Int , totalDuration: Int) {
        print("loadedTimeDidChange - \(loadedDuration) - \(totalDuration)")
        controlView.progressView.setProgress(Float(loadedDuration)/Float(totalDuration), animated: true)
    }
    
    func bmPlayer(player player: BMPlayerLayerView, playerStateDidChange state: BMPlayerState) {
        print("playerStateDidChange - \(state)")
        switch state {
        case BMPlayerState.ReadyToPlay:
            controlView.loadIndector.stopAnimating()
        case BMPlayerState.Buffering:
            cancelAutoFadeOutControlBar()
            controlView.loadIndector.startAnimating()
        case BMPlayerState.BufferFinished:
            controlView.loadIndector.stopAnimating()
        case BMPlayerState.Playing:
            autoFadeOutControlBar()
            controlView.loadIndector.stopAnimating()
            controlView.playButton.selected = true
            isSliderSliding = false
        case BMPlayerState.Pause:
            controlView.playButton.selected = false
        default:
            break
        }
    }
    
    func bmPlayer(player player: BMPlayerLayerView, playTimeDidChange currentTime: Int, totalTime: Int) {
        print("playTimeDidChange - \(currentTime) - \(totalTime)")
        self.totalTime = totalTime
        if isSliderSliding {
            return
        }
        controlView.currentTimeLabel.text = formatSecondsToString(currentTime)
        controlView.totalTimeLabel.text = formatSecondsToString(totalTime)
        
        controlView.timeSlider.value    = Float(currentTime) / Float(totalTime)
    }
}