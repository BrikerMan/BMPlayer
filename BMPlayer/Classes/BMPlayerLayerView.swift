//
//  BMPlayerLayerView.swift
//  Pods
//
//  Created by BrikerMan on 16/4/28.
//
//

import UIKit
import AVFoundation

public protocol BMPlayerLayerViewDelegate : class {
    func bmPlayer(player: BMPlayerLayerView ,playerStateDidChange state: BMPlayerState)
    func bmPlayer(player: BMPlayerLayerView ,loadedTimeDidChange  loadedDuration: TimeInterval , totalDuration: TimeInterval)
    func bmPlayer(player: BMPlayerLayerView ,playTimeDidChange    currentTime   : TimeInterval , totalTime: TimeInterval)
    func bmPlayer(player: BMPlayerLayerView ,playerIsPlaying      playing: Bool)
}

open class BMPlayerLayerView: UIView {
    
    open weak var delegate: BMPlayerLayerViewDelegate?
    
    /// 视频URL
    open var videoURL: URL! {
        didSet { onSetVideoURL() }
    }
    
    /// 视频跳转秒数置0
    open var seekTime = 0
    
    open var videoGravity = AVLayerVideoGravityResizeAspect {
        didSet {
            self.playerLayer?.videoGravity = videoGravity
        }
    }
    
    var aspectRatio:BMPlayerAspectRatio = .default {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 计时器
    var timer       : Timer?
    
    /// 播放属性
    lazy var player: AVPlayer? = {
        if let item = self.playerItem {
            let player = AVPlayer(playerItem: item)
            return player
        }
        return nil
    }()
    
    
    open var isPlaying: Bool {
        get {
            if let player = player {
                return player.rate > 0.0
            }
            return false
        }
        set {
            self.isPlayingCached = isPlaying
        }
    }
    
    fileprivate var isPlayingCached = false {
        didSet {
            if isPlayingCached != oldValue {
                delegate?.bmPlayer(player: self, playerIsPlaying: isPlayingCached)
            }
        }
    }
    
    /// 播放属性
    open var playerItem: AVPlayerItem? {
        didSet {
            onPlayerItemChange()
        }
    }
    
    fileprivate var lastPlayerItem: AVPlayerItem?
    /// playerLayer
    fileprivate var playerLayer: AVPlayerLayer?
    /// 音量滑杆
    fileprivate var volumeViewSlider: UISlider!
    /// 播发器的几种状态
    fileprivate var state = BMPlayerState.notSetURL {
        didSet {
            if state != oldValue {
                delegate?.bmPlayer(player: self, playerStateDidChange: state)
            }
        }
    }
    /// 是否为全屏
    fileprivate var isFullScreen  = false
    /// 是否锁定屏幕方向
    fileprivate var isLocked      = false
    /// 是否在调节音量
    fileprivate var isVolume      = false
    /// 是否播放本地文件
    fileprivate var isLocalVideo  = false
    /// slider上次的值
    fileprivate var sliderLastValue:Float = 0
    /// 是否点了重播
    fileprivate var repeatToPlay  = false
    /// 播放完了
    fileprivate var playDidEnd    = false
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    // 仅在bufferingSomeSecond里面使用
    fileprivate var isBuffering     = false
    
    
    
    // MARK: - Actions
    open func play() {
        if let player = player {
            player.play()
            timer?.fireDate = Date()
        }
    }
    
    
    open func pause() {
        player?.pause()
        timer?.fireDate = Date.distantFuture
    }
    
    // MARK: - 生命周期
    /**
     *  初始化player
     */
    func initializeThePlayer() {
        // TODO: 10
        // 每次播放视频都解锁屏幕锁定
        //        [self unLockTheScreen];
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        BMPlayerManager.shared.log("BMPlayerLayerView did dealloc")
    }
    
    
    // MARK: - layoutSubviews
    override open func layoutSubviews() {
        super.layoutSubviews()
        switch self.aspectRatio {
        case .default:
            self.playerLayer?.videoGravity = "AVLayerVideoGravityResizeAspect"
            self.playerLayer?.frame  = self.bounds
            break
        case .sixteen2NINE:
            self.playerLayer?.videoGravity = "AVLayerVideoGravityResize"
            self.playerLayer?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width/(16/9))
            break
        case .four2THREE:
            self.playerLayer?.videoGravity = "AVLayerVideoGravityResize"
            let _w = self.bounds.height * 4 / 3
            self.playerLayer?.frame = CGRect(x: (self.bounds.width - _w )/2, y: 0, width: _w, height: self.bounds.height)
            break
        }
        
        //        self.playerLayer?.frame  = CGRectMake(0, 0, 200, 200)
    }
    
    open func resetPlayer() {
        // 初始化状态变量
        self.playDidEnd = false
        self.playerItem = nil
        self.seekTime   = 0
        
        self.timer?.invalidate()
        
        self.pause()
        // 移除原来的layer
        self.playerLayer?.removeFromSuperlayer()
        // 替换PlayerItem为nil
        self.player?.replaceCurrentItem(with: nil)
        player?.removeObserver(self, forKeyPath: "rate")
        
        // 把player置为nil
        self.player = nil
    }
    
    open func prepareToDeinit() {
        self.timer?.invalidate()
        self.playerItem = nil
        self.resetPlayer()
    }
    
    open func onTimeSliderBegan() {
        if self.player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
            self.timer?.fireDate = Date.distantFuture
        }
    }
    
    open func seekToTime(_ secounds: TimeInterval, completionHandler:(()->Void)?) {
        if secounds.isNaN {
            return
        }
        if self.player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
            let draggedTime = CMTimeMake(Int64(secounds), 1)
            self.player!.seek(to: draggedTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (finished) in
                
            })
        }
    }
    
    
    // MARK: - 设置视频URL
    fileprivate func onSetVideoURL() {
        self.repeatToPlay = false
        self.playDidEnd   = false
        self.configPlayer()
        
    }
    
    fileprivate func onPlayerItemChange() {
        if lastPlayerItem == playerItem {
            return
        }
        
        if let item = lastPlayerItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "loadedTimeRanges")
            item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
        
        lastPlayerItem = playerItem
        
        if let item = playerItem {
            NotificationCenter.default.addObserver(self, selector: #selector(self.moviePlayDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            // 缓冲区空了，需要等待数据
            item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
            // 缓冲区有足够数据可以播放了
            item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    fileprivate func configPlayer(){
        self.player?.removeObserver(self, forKeyPath: "rate")
        
        self.playerItem = AVPlayerItem(url: videoURL)
        
        self.player     = AVPlayer(playerItem: playerItem!)
        
        self.player!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.playerLayer = AVPlayerLayer(player: player)
        
        self.playerLayer!.videoGravity = videoGravity
        
        self.layer.insertSublayer(playerLayer!, at: 0)
        
        self.timer  = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(playerTimerAction), userInfo: nil, repeats: true)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    
    // MARK: - 计时器事件
    @objc fileprivate func playerTimerAction() {
        if let playerItem = playerItem {
            if playerItem.duration.timescale != 0 {
                let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                let totalTime   = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
                delegate?.bmPlayer(player: self, playTimeDidChange: currentTime, totalTime: totalTime)
            }
            updateStatus(inclodeLoading: true)
        }
    }
    
    fileprivate func updateStatus(inclodeLoading: Bool = false) {
        if let player = player {
            if let playerItem = playerItem {
                if inclodeLoading {
                    if playerItem.isPlaybackLikelyToKeepUp || playerItem.isPlaybackBufferFull {
                        self.state = .bufferFinished
                    } else {
                        self.state = .buffering
                    }
                }
            }
            if player.rate == 0.0 {
                if player.error != nil {
                    self.state = .error
                    return
                }
                if let currentItem = player.currentItem {
                    if player.currentTime() >= currentItem.duration {
                        if self.state != .playedToTheEnd {
                            self.state = .playedToTheEnd
                        }
                        
                        return
                    }
                    if currentItem.isPlaybackLikelyToKeepUp || currentItem.isPlaybackBufferFull {
                        self.isPlaying = false
                    }
                }
            } else {
                isPlaying = true
            }
        }
    }
    
    // MARK: - Notification Event
    @objc fileprivate func moviePlayDidEnd(_ notif: Notification) {
        if state != .playedToTheEnd {
            self.state = .playedToTheEnd
            self.playDidEnd = true
        }
    }
    
    // MARK: - KVO
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item = object as? AVPlayerItem, let keyPath = keyPath {
            if item == self.playerItem {
                switch keyPath {
                case "status":
                    if player?.status == AVPlayerStatus.readyToPlay {
                        self.state = .readyToPlay
                        player?.play()
                    } else if player?.status == AVPlayerStatus.failed {
                        self.state = .error
                    }
                    
                case "loadedTimeRanges":
                    // 计算缓冲进度
                    if let timeInterVarl    = self.availableDuration() {
                        let duration        = item.duration
                        let totalDuration   = CMTimeGetSeconds(duration)
                        delegate?.bmPlayer(player: self, loadedTimeDidChange: timeInterVarl, totalDuration: totalDuration)
                    }
                    
                case "playbackBufferEmpty":
                    // 当缓冲是空的时候
                    if self.playerItem!.isPlaybackBufferEmpty {
                        self.state = .buffering
                        self.bufferingSomeSecond()
                    }
                case "playbackLikelyToKeepUp":
                    if item.isPlaybackBufferEmpty {
                        if state != .bufferFinished {
                            self.state = .bufferFinished
                            self.playDidEnd = true
                        }
                    }
                default:
                    break
                }
            }
        }
        
        if keyPath == "rate" {
            updateStatus()
        }
    }
    
    /**
     缓冲进度
     
     - returns: 缓冲进度
     */
    fileprivate func availableDuration() -> TimeInterval? {
        if let loadedTimeRanges = player?.currentItem?.loadedTimeRanges,
            let first = loadedTimeRanges.first {
            let timeRange = first.timeRangeValue
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSecound = CMTimeGetSeconds(timeRange.duration)
            let result = startSeconds + durationSecound
            return result
        }
        return nil
    }
    
    /**
     缓冲比较差的时候
     */
    fileprivate func bufferingSomeSecond() {
        self.state = .buffering
        // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
        
        if isBuffering {
            return
        }
        isBuffering = true
        // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
        player?.pause()
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 1.0 )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            
            // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
            self.isBuffering = false
            if let item = self.playerItem {
                if !item.isPlaybackLikelyToKeepUp {
                    self.bufferingSomeSecond()
                } else {
                    // 如果此时用户已经暂停了，则不再需要开启播放了
                    self.state = BMPlayerState.bufferFinished
                }
            }
        }
    }
}
