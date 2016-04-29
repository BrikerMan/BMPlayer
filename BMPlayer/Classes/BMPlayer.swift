//
//  BMPlayer.swift
//  Pods
//
//  Created by BrikerMan on 16/4/28.
//
//

import UIKit
import SnapKit

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

public class BMPlayer: UIView {
    
    public var backBlock:(() -> Void)?
    
    var playerLayer: BMPlayerLayerView!
    
    var controlView: BMPlayerControlView!
    
    private var isMaskShowing = false
    private var isFullScreen  = false
    
    private let BMPlayerAnimationTimeInterval:Double                = 4.0
    private let BMPlayerControlBarAutoFadeOutTimeInterval:Double    = 0.5
    
    // MARK: - Public functions
    public func playWithURL(url: NSURL) {
        playerLayer = BMPlayerLayerView()
        insertSubview(playerLayer, atIndex: 0)
        playerLayer.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        playerLayer.delegate = self
        playerLayer.videoURL = url
        controlView.loadIndector.startAnimating()
        self.layoutIfNeeded()
    }
    
    public func play() {
        playerLayer.play()
    }
    
    public func pause() {
        playerLayer.pause()
    }
    
    func autoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideControlViewAnimated), object: nil)
        self.performSelector(#selector(hideControlViewAnimated), withObject: nil, afterDelay: BMPlayerAnimationTimeInterval)
    }
    
    func cancelAutoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    // MARK: - Action Response
    @objc private func hideControlViewAnimated() {
        UIView.animateWithDuration(BMPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.hideIcons()
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            
        }) { (_) in
            self.isMaskShowing = false
        }
    }
    
    @objc private func showControlViewAnimated() {
        UIView.animateWithDuration(BMPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.showIcons()
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
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
    
    @objc private func progressSliderTouchBegan(sender: UISlider)  {
        playerLayer.onTimeSliderBegan()
        cancelAutoFadeOutControlBar()
    }
    
    @objc private func progressSliderValueChanged(sender: UISlider)  {
        self.pause()
    }
    
    @objc private func progressSliderTouchEnded(sender: UISlider)  {
        controlView.loadIndector.startAnimating()
        autoFadeOutControlBar()
        playerLayer.onSliderTouchEnd(withValue: sender.value)
    }
    
    @objc private func backButtonPressed(button: UIButton) {
        if isFullScreen {
            fullScreenButtonPressed(nil)
        } else {
            playerLayer.prepareToDeinit()
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
        playerLayer.pause()
        playerLayer.prepareToDeinit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initUIData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        initUIData()
    }
    
    private func formatSecondsToString(secounds: Int) -> String {
        let Min = secounds / 60
        let Sec = secounds % 60
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    // MARK: - 初始化
    private func initUI() {
        
        controlView =  BMPlayerControlView()
        addSubview(controlView)
        controlView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureTapped(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    private func initUIData() {
        controlView.playButton.addTarget(self, action: #selector(self.playButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.fullScreenButton.addTarget(self, action: #selector(self.fullScreenButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.backButton.addTarget(self, action: #selector(self.backButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), forControlEvents: UIControlEvents.TouchDown)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), forControlEvents: [UIControlEvents.TouchUpInside,UIControlEvents.TouchCancel, UIControlEvents.TouchUpOutside])
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
        case BMPlayerState.Pause:
            controlView.playButton.selected = false
        default:
            break
        }
    }
    
    func bmPlayer(player player: BMPlayerLayerView, playTimeDidChange currentTime: Int, totalTime: Int) {
        print("playTimeDidChange - \(currentTime) - \(totalTime)")
        controlView.currentTimeLabel.text = formatSecondsToString(currentTime)
        controlView.totalTimeLabel.text = formatSecondsToString(totalTime)
        
        controlView.timeSlider.value    = Float(currentTime) / Float(totalTime)
    }
}