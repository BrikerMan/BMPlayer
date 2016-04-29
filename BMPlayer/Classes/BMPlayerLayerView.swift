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
    func bmPlayer(player player: BMPlayerLayerView ,loadedTimeDidChange  progressValue: Float)
    func bmPlayer(player player: BMPlayerLayerView ,playTimeDidChange    currentTime: Int, totalTime: Int)
    
}

class BMPlayerLayerView: UIView {
    /// 视频URL
    var videoURL: NSURL! {
        didSet { onSetVideoURL() }
    }
    
    /// 视频跳转秒数置0
    var seekTime = 0
    
    /// 枚举值，包含水平移动方向和垂直移动方向
    private enum PanDirection {
        case HorizontalMoved
        case VerticalMoved
    }
    
    /// 播放属性
    lazy private var player: AVPlayer? = {
        if let item = self.playerItem {
            return  AVPlayer(playerItem: item)
        }
        return nil
    }()
    /// 播放属性
    private var playerItem: AVPlayerItem? {
        didSet {
            
        }
    }
    
    private var lastPlayerItem: AVPlayerItem?
    /// playerLayer
    private var playerLayer: AVPlayerLayer?
    /// 音量滑杆
    private var volumeViewSlider: UISlider!
    /// 计时器
    private var timer       : NSTimer?
    
    /// 用来保存快进的总时长
    private var sumTime     : CGFloat!
    /// 滑动方向
    private var panDirection: PanDirection!
    /// 播发器的几种状态
    private var state = BMPlayerState.NotSetURL
    /// 是否为全屏
    private var isFullScreen  = false
    /// 是否锁定屏幕方向
    private var isLocked      = false
    /// 是否在调节音量
    private var isVolume      = false
    /// 是否显示controlView
    private var isMaskShowing = false
    /// 是否被用户暂停
    private var isPauseByUser = false
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
            player.play()
            self.state = .Playing
        }
    }
    
    
    func pause() {
        if let player = player {
            player.pause()
            self.state = .Pause
        }
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
        print("BMPlayerView deint")
    }
    
    
    // MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame  = self.bounds
        self.isMaskShowing      = false
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
    
    // MARK: - 设置视频URL
    
    private func onSetVideoURL() {
        self.repeatToPlay = false
        self.playDidEnd   = false
        self.configPlayer()
        
    }
    
    func configPlayer(){
        self.playerItem = AVPlayerItem(URL: videoURL)
        
        self.player     = AVPlayer(playerItem: playerItem!)
        
        self.playerLayer = AVPlayerLayer(player: player)
        
        self.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        
        self.layer.insertSublayer(playerLayer!, atIndex: 0)
        
//        self.timer  = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(playerTimerAction), userInfo: nil, repeats: true)
        //        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        
        self.state      = .Buffering
        
        self.play()
        self.isPauseByUser  = false
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}
