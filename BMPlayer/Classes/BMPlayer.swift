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

public enum BMPlayerState {
    case notSetURL      // 未设置URL
    case readyToPlay    // 可以播放
    case buffering      // 缓冲中
    case bufferFinished // 缓冲完毕
    case playedToTheEnd // 播放结束
    case error          // 出现错误
}

/// 枚举值，包含水平移动方向和垂直移动方向
enum BMPanDirection: Int {
    case horizontal = 0
    case vertical   = 1
}

//enum BMPlayerItemType {
//    case url
//    case bmPlayerItem
//}
// 视频画面比例
public enum BMPlayerAspectRatio : Int {
    case `default` = 0    //视频源默认比例
    case sixteen2NINE   //16：9
    case four2THREE     //4：3
}

public protocol BMPlayerDelegate : class {
    func bmPlayer(player: BMPlayer ,playerStateDidChange state: BMPlayerState)
    func bmPlayer(player: BMPlayer ,loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval)
    func bmPlayer(player: BMPlayer ,playTimeDidChange currentTime : TimeInterval, totalTime: TimeInterval)
    func bmPlayer(player: BMPlayer ,playerIsPlaying playing: Bool)
}

open class BMPlayer: UIView {
    
    open weak var delegate: BMPlayerDelegate?
    
    open var backBlock:((Bool) -> Void)?
    
    /// Gesture used to show / hide control view
    open var tapGesture: UITapGestureRecognizer!
    
    /// Gesture to change volume / brightness
    open var panGesture: UIPanGestureRecognizer!
    
    /// AVLayerVideoGravityType
    open var videoGravity = AVLayerVideoGravityResizeAspect {
        didSet {
            self.playerLayer?.videoGravity = videoGravity
        }
    }
    
    open var isPlaying: Bool {
        get {
            return playerLayer?.isPlaying ?? false
        }
    }
    
    //Closure fired when play time changed
    open var playTimeDidChange:((TimeInterval, TimeInterval) -> Void)?
    //Closure fired when play state chaged
    open var playStateDidChange:((Bool) -> Void)?
    
    
    fileprivate var resource: BMPlayerResource!
    
    //    fileprivate var videoItem: BMPlayerItem!
    
    fileprivate var currentDefinition = 0
    
    fileprivate var playerLayer: BMPlayerLayerView?
    
    fileprivate var controlView: BMPlayerCustomControlView!
    
    fileprivate var customControllView: BMPlayerCustomControlView?
    
    //    fileprivate var playerItemType = BMPlayerItemType.url
    
    fileprivate var videoItemURL: URL!
    
    fileprivate var videoTitle = ""
    
    fileprivate var isFullScreen:Bool {
        get {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
    
    /// 滑动方向
    fileprivate var panDirection = BMPanDirection.horizontal
    /// 音量滑竿
    fileprivate var volumeViewSlider: UISlider!
    
    fileprivate let BMPlayerAnimationTimeInterval:Double                = 4.0
    fileprivate let BMPlayerControlBarAutoFadeOutTimeInterval:Double    = 0.5
    
    /// 用来保存时间状态
    fileprivate var sumTime         : TimeInterval = 0
    fileprivate var totalDuration   : TimeInterval = 0
    fileprivate var currentPosition : TimeInterval = 0
    fileprivate var shouldSeekTo    : TimeInterval = 0
    
    fileprivate var isURLSet        = false
    fileprivate var isSliderSliding = false
    fileprivate var isPauseByUser   = false
    fileprivate var isVolume        = false
    fileprivate var isMaskShowing   = false
    fileprivate var isSlowed        = false
    fileprivate var isMirrored      = false
    fileprivate var isPlayToTheEnd  = false {
        didSet { controlView.playerReplayButton?.isHidden = !isPlayToTheEnd }
    }
    
    //视频画面比例
    fileprivate var aspectRatio:BMPlayerAspectRatio = .default
    
    //Cache is playing result to improve callback performance
    fileprivate var isPlayingCache: Bool? = nil
    
    // MARK: - Public functions
    
    /**
     Play
     
     - parameter resource:        media resource
     - parameter definitionIndex: starting definition index, default start with the first definition
     */
    open func setVideo(resource: BMPlayerResource, definitionIndex: Int = 0) {
        self.resource = resource
        controlView.playerTitleLabel?.text = resource.name
        currentDefinition           = definitionIndex
        
        if resource.definitions.count > 1 {
            controlView.prepareChooseDefinitionView(resource.definitions, index: definitionIndex)
        }
        
        if BMPlayerConf.shouldAutoPlay {
            let asset = resource.definitions[definitionIndex]
            playerLayer?.playAsset(asset: asset.avURLAsset)
        } else {
            controlView.showCover(url: resource.cover)
            controlView.hideLoader()
        }
    }
    
    /**
     直接使用URL播放
     
     - parameter url:   视频URL
     - parameter title: 视频标题
     */
    @available(*, deprecated: 0.8.0, renamed: "setVideo(resource:)")
    open func playWithURL(_ url: URL, title: String = "") {
        let asset = BMPlayerResource(url: url, name: title, cover: nil)
        setVideo(resource: asset)
    }
    
    /**
     播放可切换清晰度的视频
     
     - parameter items: 清晰度列表
     - parameter title: 视频标题
     - parameter definitionIndex: 起始清晰度
     */
    @available(*, deprecated: 0.8.0, renamed: "setVideo(resource:definitionIndex:)")
    open func playWithPlayerItem(_ item:BMPlayerItem, definitionIndex: Int = 0) {
        var models: [BMPlayerResourceDefinition] = []
        
        for def in item.resource {
            let model = BMPlayerResourceDefinition(url: def.playURL, definition: def.definitionName)
            models.append(model)
        }
        
        let asset = BMPlayerResource(name: item.title, definitions: models, cover: URL(string: item.cover))
        setVideo(resource: asset)
    }
    
    /**
     auto start playing, call at viewWillAppear, See more at pause
     */
    open func autoPlay() {
        if !isPauseByUser && isURLSet && !isPlayToTheEnd {
            self.play()
        }
    }
    
    /**
     Play
     */
    open func play() {
        if videoItemURL == nil && resource == nil {
            return
        }
        if !isURLSet {
            let asset = resource.definitions[currentDefinition]
            playerLayer?.playAsset(asset: asset.avURLAsset)
            controlView.hideCoverImageView()
            isURLSet                = true
        }
        
        controlView.playerPlayButton?.isSelected = true
        playerLayer?.play()
        isPauseByUser = false
    }
    
    /**
     Pause
     
     - parameter allow: should allow to response `autoPlay` function
     */
    open func pause(allowAutoPlay allow: Bool = false) {
        controlView.playerPlayButton?.isSelected = false
        playerLayer?.pause()
        isPauseByUser = !allow
    }
    
    /**
     seek
     
     - parameter to: target time
     */
    open func seek(_ to:TimeInterval) {
        self.shouldSeekTo = to
        playerLayer?.seekToTime(to, completionHandler: {
            self.shouldSeekTo = 0
        })
    }
    
    /**
     start count down to fade out control UI
     */
    open func autoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControlViewAnimated), object: nil)
        self.perform(#selector(hideControlViewAnimated), with: nil, afterDelay: BMPlayerAnimationTimeInterval)
    }
    
    /**
     cancel auto fade out control UI count down
     */
    open func cancelAutoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControlViewAnimated), object: nil)
    }
    
    /**
     update UI to fullScreen
     */
    open func updateUI(_ isFullScreen: Bool) {
        controlView.updateUI(isFullScreen)
    }
    
    /**
     increade volume with step, default step 0.1
     
     - parameter step: step
     */
    open func addVolume(step: Float = 0.1) {
        self.volumeViewSlider.value += step
    }
    
    /**
     decreace volume with step, default step 0.1
     
     - parameter step: step
     */
    open func reduceVolume(step: Float = 0.1) {
        self.volumeViewSlider.value -= step
    }
    
    /**
     prepare to dealloc player, call at View or Controllers deinit funciton.
     */
    open func prepareToDealloc() {
        playerLayer?.prepareToDeinit()
    }
    
    
    // MARK: - Action Response
    fileprivate func playStateDidChanged() {
        if isSliderSliding || isPlayToTheEnd { return }
        if let player = playerLayer {
            if player.isPlaying {
                autoFadeOutControlBar()
                controlView.playerPlayButton?.isSelected = true
            } else {
                controlView.playerPlayButton?.isSelected = false
            }
            if isPlayingCache != player.isPlaying && playStateDidChange != nil {
                isPlayingCache = player.isPlaying
                DispatchQueue.global(qos: .utility).async {
                    self.playStateDidChange!(player.isPlaying)
                }
            }
        }
    }
    
    
    @objc fileprivate func hideControlViewAnimated() {
        UIView.animate(withDuration: BMPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.hidePlayerUIComponents()
            if self.isFullScreen {
                UIApplication.shared.setStatusBarHidden(true, with: .fade)
            }
        }, completion: { (_) in
            self.isMaskShowing = false
        })
    }
    
    @objc fileprivate func showControlViewAnimated(autoHide: Bool = true) {
        UIView.animate(withDuration: BMPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.showPlayerUIComponents()
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
        }, completion: { (_) in
            if autoHide {
                self.autoFadeOutControlBar()
            }
            self.isMaskShowing = true
        })
    }
    
    @objc fileprivate func tapGestureTapped(_ sender: UIGestureRecognizer) {
        if isMaskShowing {
            hideControlViewAnimated()
            autoFadeOutControlBar()
        } else {
            showControlViewAnimated()
        }
    }
    
    @objc fileprivate func panDirection(_ pan: UIPanGestureRecognizer) {
        // 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.location(in: self)
        
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint = pan.velocity(in: self)
        
        // 判断是垂直移动还是水平移动
        switch pan.state {
        case UIGestureRecognizerState.began:
            // 使用绝对值来判断移动的方向
            
            let x = fabs(velocityPoint.x)
            let y = fabs(velocityPoint.y)
            
            if x > y {
                self.panDirection = BMPanDirection.horizontal
                
                // 给sumTime初值
                if let player = playerLayer?.player {
                    let time = player.currentTime()
                    self.sumTime = TimeInterval(time.value) / TimeInterval(time.timescale)
                }
                
            } else {
                self.panDirection = BMPanDirection.vertical
                if locationPoint.x > self.bounds.size.width / 2 {
                    self.isVolume = true
                } else {
                    self.isVolume = false
                }
            }
            
        case UIGestureRecognizerState.changed:
            cancelAutoFadeOutControlBar()
            switch self.panDirection {
            case BMPanDirection.horizontal:
                self.horizontalMoved(velocityPoint.x)
            case BMPanDirection.vertical:
                self.verticalMoved(velocityPoint.y)
            }
        case UIGestureRecognizerState.ended:
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
            case BMPanDirection.horizontal:
                controlView.hideSeekToView()
                isSliderSliding = false
                if isPlayToTheEnd {
                    isPlayToTheEnd = false
                    playerLayer?.seekToTime(self.sumTime, completionHandler: {
                        self.play()
                        self.play()
                    })
                } else {
                    playerLayer?.seekToTime(self.sumTime, completionHandler: {
                        self.autoPlay()
                    })
                }
                // 把sumTime滞空，不然会越加越多
                self.sumTime = 0.0
                
            //                controlView.showLoader()
            case BMPanDirection.vertical:
                self.isVolume = false
            }
        default:
            break
        }
    }
    
    fileprivate func verticalMoved(_ value: CGFloat) {
        self.isVolume ? (self.volumeViewSlider.value -= Float(value / 10000)) : (UIScreen.main.brightness -= value / 10000)
    }
    
    fileprivate func horizontalMoved(_ value: CGFloat) {
        isSliderSliding = true
        if let playerItem = playerLayer?.playerItem {
            // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
            self.sumTime = self.sumTime + TimeInterval(value) / 100.0 * (TimeInterval(self.totalDuration)/400)
            
            let totalTime       = playerItem.duration
            
            // 防止出现NAN
            if totalTime.timescale == 0 { return }
            
            let totalDuration   = TimeInterval(totalTime.value) / TimeInterval(totalTime.timescale)
            if (self.sumTime > totalDuration) { self.sumTime = totalDuration}
            if (self.sumTime < 0){ self.sumTime = 0}
            
            let targetTime      = formatSecondsToString(sumTime)
            
            controlView.playerTimeSlider?.value      = Float(sumTime / totalDuration)
            controlView.playerCurrentTimeLabel?.text       = targetTime
            controlView.showSeekToView(sumTime, isAdd: value > 0)
        }
    }
    
    @objc fileprivate func progressSliderTouchBegan(_ sender: UISlider)  {
        playerLayer?.onTimeSliderBegan()
        isSliderSliding = true
    }
    
    @objc fileprivate func progressSliderValueChanged(_ sender: UISlider)  {
        //        self.pause(allowAutoPlay: true)
        cancelAutoFadeOutControlBar()
    }
    
    @objc fileprivate func progressSliderTouchEnded(_ sender: UISlider)  {
        isSliderSliding = false
        autoFadeOutControlBar()
        let target = self.totalDuration * Double(sender.value)
        
        if isPlayToTheEnd {
            isPlayToTheEnd = false
            playerLayer?.seekToTime(target, completionHandler: {
                self.play()
                self.play()
            })
        } else {
            playerLayer?.seekToTime(target, completionHandler: {
                self.autoPlay()
            })
        }
    }
    
    @objc fileprivate func backButtonPressed(_ button: UIButton) {
        if isFullScreen {
            fullScreenButtonPressed(nil)
        } else {
            playerLayer?.prepareToDeinit()
        }
        if let block = backBlock {
            block(isFullScreen)
        }
    }
    
    @objc fileprivate func slowButtonPressed(_ button: UIButton) {
        autoFadeOutControlBar()
        if isSlowed {
            self.playerLayer?.player?.rate = 1.0
            self.isSlowed = false
            self.controlView.playerSlowButton?.setTitle("慢放", for: UIControlState())
        } else {
            self.playerLayer?.player?.rate = 0.5
            self.isSlowed = true
            self.controlView.playerSlowButton?.setTitle("正常", for: UIControlState())
        }
    }
    
    @objc fileprivate func mirrorButtonPressed(_ button: UIButton) {
        autoFadeOutControlBar()
        if isMirrored {
            self.playerLayer?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.isMirrored = false
            self.controlView.playerMirrorButton?.setTitle("镜像", for: UIControlState())
        } else {
            self.playerLayer?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.isMirrored = true
            self.controlView.playerMirrorButton?.setTitle("正常", for: UIControlState())
        }    }
    
    @objc fileprivate func replayButtonPressed() {
        playerLayer?.seekToTime(0, completionHandler: {
            
        })
        controlView.playerReplayButton?.isHidden = true
        isPlayToTheEnd = false
        playerLayer?.isPlaying = true
        self.play()
    }
    
    @objc fileprivate func playButtonPressed(_ button: UIButton) {
        if button.isSelected {
            self.pause()
        } else {
            if isPlayToTheEnd {
                isPlayToTheEnd = false
                replayButtonPressed()
            }
            self.play()
        }
    }
    
    @objc fileprivate func ratioButtonPressed(_ button: UIButton) {
        var _ratio = self.aspectRatio.rawValue + 1
        if _ratio > 2 {
            _ratio = 0
        }
        self.aspectRatio = BMPlayerAspectRatio(rawValue: _ratio)!
        self.controlView.aspectRatioChanged(self.aspectRatio)
        self.playerLayer?.aspectRatio = self.aspectRatio
    }
    
    @objc fileprivate func onOrientationChanged() {
        self.updateUI(isFullScreen)
    }
    
    @objc fileprivate func fullScreenButtonPressed(_ button: UIButton?) {
        if !isURLSet {
            //            self.play()
        }
        controlView.updateUI(!self.isFullScreen)
        if isFullScreen {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            UIApplication.shared.statusBarOrientation = .portrait
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }
    }
    
    // MARK: - 生命周期
    deinit {
        playerLayer?.pause()
        playerLayer?.prepareToDeinit()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        initUIData()
        configureVolume()
        preparePlayer()
    }
    
    public convenience init (customControllView: BMPlayerCustomControlView?) {
        self.init(frame:CGRect.zero)
        self.customControllView = customControllView
        initUI()
        initUIData()
        configureVolume()
        preparePlayer()
    }
    
    public convenience init() {
        self.init(customControllView:nil)
    }
    
    
    
    fileprivate func formatSecondsToString(_ secounds: TimeInterval) -> String {
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    // MARK: - 初始化
    fileprivate func initUI() {
        self.backgroundColor = UIColor.black
        
        if let customView = customControllView {
            controlView = customView
        } else {
            controlView =  BMPlayerControlView()
        }
        
        addSubview(controlView.getView)
        controlView.updateUI(isFullScreen)
        controlView.delegate = self
        controlView.getView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureTapped(_:)))
        self.addGestureRecognizer(tapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panDirection(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    fileprivate func initUIData() {
        controlView.playerPlayButton?.addTarget(self, action: #selector(self.playButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        controlView.playerFullScreenButton?.addTarget(self, action: #selector(self.fullScreenButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        controlView.playerBackButton?.addTarget(self, action: #selector(self.backButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: UIControlEvents.touchDown)
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: UIControlEvents.valueChanged)
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [UIControlEvents.touchUpInside,UIControlEvents.touchCancel, UIControlEvents.touchUpOutside])
        controlView.playerSlowButton?.addTarget(self, action: #selector(slowButtonPressed(_:)), for: .touchUpInside)
        controlView.playerMirrorButton?.addTarget(self, action: #selector(mirrorButtonPressed(_:)), for: .touchUpInside)
        controlView.playerRatioButton?.addTarget(self, action: #selector(self.ratioButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    fileprivate func configureVolume() {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                self.volumeViewSlider = slider
            }
        }
    }
    
    fileprivate func preparePlayer() {
        playerLayer = BMPlayerLayerView()
        playerLayer!.videoGravity = videoGravity
        insertSubview(playerLayer!, at: 0)
        playerLayer!.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        playerLayer!.delegate = self
        controlView.showLoader()
        self.layoutIfNeeded()
    }
}

extension BMPlayer: BMPlayerLayerViewDelegate {
    public func bmPlayer(player: BMPlayerLayerView, playerIsPlaying playing: Bool) {
        playStateDidChanged()
        delegate?.bmPlayer(player: self, playerIsPlaying: playing)
    }
    
    public func bmPlayer(player: BMPlayerLayerView ,loadedTimeDidChange  loadedDuration: TimeInterval , totalDuration: TimeInterval) {
        BMPlayerManager.shared.log("loadedTimeDidChange - \(loadedDuration) - \(totalDuration)")
        delegate?.bmPlayer(player: self, loadedTimeDidChange: loadedDuration, totalDuration: totalDuration)
        
        self.totalDuration = totalDuration
        controlView.playerProgressView?.setProgress(Float(loadedDuration)/Float(totalDuration), animated: true)
    }
    
    public func bmPlayer(player: BMPlayerLayerView, playerStateDidChange state: BMPlayerState) {
        BMPlayerManager.shared.log("playerStateDidChange - \(state)")
        delegate?.bmPlayer(player: self, playerStateDidChange: state)
        
        switch state {
        case BMPlayerState.readyToPlay:
            if shouldSeekTo != 0 {
                playerLayer?.seekToTime(shouldSeekTo, completionHandler: {
                    
                })
                shouldSeekTo = 0
            }
            controlView.hideLoader()
            self.play()
        case BMPlayerState.buffering:
            cancelAutoFadeOutControlBar()
            controlView.showLoader()
            playStateDidChanged()
        case BMPlayerState.bufferFinished:
            controlView.hideLoader()
            playStateDidChanged()
            autoPlay()
            
        case BMPlayerState.playedToTheEnd:
            isPlayToTheEnd = true
            controlView.playerPlayButton?.isSelected = false
            controlView.showPlayToTheEndView()
            showControlViewAnimated(autoHide: false)
            cancelAutoFadeOutControlBar()
        default:
            break
        }
        
        tapGesture.isEnabled =  state != .playedToTheEnd
    }
    
    public func bmPlayer(player: BMPlayerLayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        BMPlayerManager.shared.log("playTimeDidChange - \(currentTime) - \(totalTime)")
        delegate?.bmPlayer(player: self, playTimeDidChange: currentTime, totalTime: totalTime)
        self.currentPosition = currentTime
        totalDuration = totalTime
        if isSliderSliding {
            return
        }
        controlView.playerCurrentTimeLabel?.text = formatSecondsToString(currentTime)
        controlView.playerTotalTimeLabel?.text = formatSecondsToString(totalTime)
        
        controlView.playerTimeSlider?.value    = Float(currentTime) / Float(totalTime)
        
        if playTimeDidChange != nil {
            DispatchQueue.global(qos: .utility).async {
                self.playTimeDidChange!(currentTime, totalTime)
            }
        }
    }
}

extension BMPlayer: BMPlayerControlViewDelegate {
    public func controlViewDidChooseDefition(_ index: Int) {
        shouldSeekTo = currentPosition
        playerLayer?.resetPlayer()
        currentDefinition = index
        playerLayer?.playAsset(asset: resource.definitions[index].avURLAsset)
        
    }
    
    public func controlViewDidPressOnReply() {
        replayButtonPressed()
    }
}
