//
//  BMPlayerLayerView.swift
//  Pods
//
//  Created by BrikerMan on 16/4/28.
//
//

import UIKit
import AVFoundation

protocol BMPlayerLayerViewDelegate : class {
    func bmPlayer(player player: BMPlayerLayerView ,playerStateDidChange state: BMPlayerState)
    func bmPlayer(player player: BMPlayerLayerView ,loadedTimeDidChange  loadedDuration: NSTimeInterval , totalDuration: NSTimeInterval)
    func bmPlayer(player player: BMPlayerLayerView ,playTimeDidChange    currentTime   : NSTimeInterval , totalTime: NSTimeInterval)
    func bmPlayer(player player: BMPlayerLayerView ,playerIsPlaying      playing: Bool)
}

class BMPlayerLayerView: UIView {
    
    weak var delegate: BMPlayerLayerViewDelegate?
    
    /// 视频URL
    var videoURL: NSURL! {
        didSet { onSetVideoURL() }
    }
    
    /// 视频跳转秒数置0
    var seekTime = 0
    
    /// 计时器
    var timer       : NSTimer?
    
    /// 播放属性
    lazy var player: AVPlayer? = {
        if let item = self.playerItem {
            return  AVPlayer(playerItem: item)
        }
        return nil
    }()
    
    
    var isPlaying     = false {
        didSet {
            delegate?.bmPlayer(player: self, playerIsPlaying: isPlaying)
        }
    }
    
    /// 播放属性
    var playerItem: AVPlayerItem? {
        didSet {
            onPlayerItemChange()
        }
    }
    
    private var lastPlayerItem: AVPlayerItem?
    /// playerLayer
    private var playerLayer: AVPlayerLayer?
    /// 音量滑杆
    private var volumeViewSlider: UISlider!
    /// 播发器的几种状态
    private var state = BMPlayerState.NotSetURL {
        didSet {
            delegate?.bmPlayer(player: self, playerStateDidChange: state)
        }
    }
    /// 是否为全屏
    private var isFullScreen  = false
    /// 是否锁定屏幕方向
    private var isLocked      = false
    /// 是否在调节音量
    private var isVolume      = false
    /// 是否播放本地文件
    private var isLocalVideo  = false
    /// slider上次的值
    private var sliderLastValue:Float = 0
    /// 是否点了重播
    private var repeatToPlay  = false
    /// 播放完了
    private var playDidEnd    = false
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    // 仅在bufferingSomeSecond里面使用
    private var isBuffering     = false
    
    
    // MARK: - Actions
    func play() {
        if let player = player {
            isPlaying = true
            player.play()
            timer?.fireDate = NSDate()
        }
    }
    
    
    func pause() {
        player?.pause()
        isPlaying  = false
        timer?.fireDate = NSDate.distantFuture()
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
        BMPlayerManager.shared.log("BMPlayerLayerView did dealloc")
    }
    
    
    // MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame  = self.bounds
    }
    
    func resetPlayer() {
        // 初始化状态变量
        self.playDidEnd = false
        self.playerItem = nil
        self.seekTime   = 0
        
        self.timer?.invalidate()
        
        self.pause()
        // 移除原来的layer
        self.playerLayer?.removeFromSuperlayer()
        // 替换PlayerItem为nil
        self.player?.replaceCurrentItemWithPlayerItem(nil)
        // 把player置为nil
        self.player = nil
    }
    
    func prepareToDeinit() {
        self.timer?.invalidate()
        self.playerItem = nil
        self.resetPlayer()
    }
    
    func onTimeSliderBegan() {
        if self.player?.currentItem?.status == AVPlayerItemStatus.ReadyToPlay {
            self.timer?.fireDate = NSDate.distantFuture()
        }
    }
    
    func seekToTime(secounds: Int, completionHandler:(()->Void)?) {
        if self.player?.currentItem?.status == AVPlayerItemStatus.ReadyToPlay {
            let draggedTime = CMTimeMake(Int64(secounds), 1)
            self.player!.seekToTime(draggedTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (finished) in
                
            })
        }
    }
    
    
    // MARK: - 设置视频URL
    private func onSetVideoURL() {
        self.repeatToPlay = false
        self.playDidEnd   = false
        self.configPlayer()
        
    }
    
    
    
    private func onPlayerItemChange() {
        if lastPlayerItem == playerItem {
            return
        }
        
        if let item = lastPlayerItem {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "loadedTimeRanges")
            item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
        
        lastPlayerItem = playerItem
        
        if let item = playerItem {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.moviePlayDidEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
            item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
            item.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.New, context: nil)
            // 缓冲区空了，需要等待数据
            item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.New, context: nil)
            // 缓冲区有足够数据可以播放了
            item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.New, context: nil)
        }
    }
    
    private func configPlayer(){
        self.playerItem = AVPlayerItem(URL: videoURL)
        
        self.player     = AVPlayer(playerItem: playerItem!)
        
        self.playerLayer = AVPlayerLayer(player: player)
        
        self.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        
        self.layer.insertSublayer(playerLayer!, atIndex: 0)
        
        self.timer  = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(playerTimerAction), userInfo: nil, repeats: true)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    
    // MARK: - 计时器事件
    @objc private func playerTimerAction() {
        if let playerItem = playerItem {
            if playerItem.duration.timescale != 0 {
                let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                let totalTime   = NSTimeInterval(playerItem.duration.value) / NSTimeInterval(playerItem.duration.timescale)
                delegate?.bmPlayer(player: self, playTimeDidChange: currentTime, totalTime: totalTime)
            }
        }
    }
    
    
    // MARK: - Notification Event
    @objc private func moviePlayDidEnd(notif: NSNotification) {
        self.state   = BMPlayerState.PlayedToTheEnd
        self.playDidEnd = true
    }
    
    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let item = object as? AVPlayerItem, keyPath = keyPath {
            if item == self.playerItem {
                switch keyPath {
                case "status":
                    if player?.status == AVPlayerStatus.ReadyToPlay {
                        self.state = .ReadyToPlay
                        player?.play()
                    } else if player?.status == AVPlayerStatus.Failed {
                        self.state = .Error
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
                    if self.playerItem!.playbackBufferEmpty {
                        self.state = .Buffering
                        self.bufferingSomeSecond()
                    }
                case "playbackLikelyToKeepUp":
                    if item.playbackBufferEmpty {
                        if state != .BufferFinished {
                            self.state = .BufferFinished
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    /**
     缓冲进度
     
     - returns: 缓冲进度
     */
    private func availableDuration() -> NSTimeInterval? {
        if let loadedTimeRanges = player?.currentItem?.loadedTimeRanges,
            first = loadedTimeRanges.first {
            let timeRange = first.CMTimeRangeValue
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
    private func bufferingSomeSecond() {
        self.state = .Buffering
        // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
        
        if isBuffering {
            return
        }
        isBuffering = true
        // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
        player?.pause()
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * 1.0 ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            
            // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
            self.isBuffering = false
            if let item = self.playerItem {
                if !item.playbackLikelyToKeepUp {
                    self.bufferingSomeSecond()
                } else {
                    // 如果此时用户已经暂停了，则不再需要开启播放了
                    self.state = BMPlayerState.BufferFinished
                }
            }
        }
    }
}
