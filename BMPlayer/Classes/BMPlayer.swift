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
    case MediaInfoReady // 获取媒体信息
    case Buffering      // 缓冲中
    case BufferFinished // 播放中
    case ReadyToPlay    // 播放中
    case Playing        // 播放中
    case Stopped        // 停止播放
    case Pause          // 暂停播放
    case PlayedToTheEnd //
    case Error
}

func BMResourcePath(fileName: String) -> String {
    return "BMPLayer.bundle/" + fileName
}

public class BMPlayer: UIView {
    
    var playerLayer: BMPlayerLayerView!
    
    var maskImageView    : UIImageView!
    var currentTimeLabel : UILabel!
    var totalTimeLabel   : UILabel!
    
    var timeSlider       : UISlider!
    var progressView     : UIProgressView!
    var fullScreenButton : UIButton!
    
    var centerButton     : UIButton!
    var loadIndector     : UIActivityIndicatorView!
    
    public func playWithURL(url: NSURL) {
        playerLayer = BMPlayerLayerView()
        insertSubview(playerLayer, atIndex: 1)
        playerLayer.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        playerLayer.delegate = self
        playerLayer.videoURL = url
        loadIndector.startAnimating()
        self.layoutIfNeeded()
    }
    
    public func play() {
        playerLayer.play()
    }
    
    public func pause() {
        playerLayer.pause()
    }
    
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
    
    @objc private func progressSliderTouchBegan(sender: UISlider)  {
        playerLayer.onTimeSliderBegan()
    }
    
    @objc private func progressSliderValueChanged(sender: UISlider)  {
        centerButton.hidden = true
        self.pause()
    }
    
    @objc private func progressSliderTouchEnded(sender: UISlider)  {
        centerButton.hidden = false
        loadIndector.startAnimating()
        playerLayer.onSliderTouchEnd(withValue: sender.value)
    }
    
    private func formatSecondsToString(secounds: Int) -> String {
        let Min = secounds / 60
        let Sec = secounds % 60
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    private func initUI() {
        maskImageView    = UIImageView()
        addSubview(maskImageView)
        
        currentTimeLabel = UILabel()
        totalTimeLabel   = UILabel()
        
        currentTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.textColor   = UIColor.whiteColor()
        currentTimeLabel.font      = UIFont.systemFontOfSize(12)
        totalTimeLabel.font      = UIFont.systemFontOfSize(12)
        
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        
        timeSlider       = UISlider()
        progressView     = UIProgressView()
        fullScreenButton = UIButton()
        addSubview(timeSlider)
        addSubview(progressView)
        addSubview(fullScreenButton)
        
        loadIndector     = UIActivityIndicatorView()
        centerButton     = UIButton()
        addSubview(loadIndector)
        addSubview(centerButton)
        
        addSnapKitConstraint()
    }
    
    
    private func addSnapKitConstraint() {
        maskImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        currentTimeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(self.snp_left).offset(10)
            make.bottom.equalTo(self.snp_bottom).offset(-10)
        }
        
        timeSlider.snp_makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(currentTimeLabel.snp_right).offset(10)
        }
        
        totalTimeLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(timeSlider.snp_right).offset(10)
        }
        
        fullScreenButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(totalTimeLabel.snp_right)
            make.right.equalTo(self.snp_right)
        }
        
        loadIndector.snp_makeConstraints { (make) in
            make.center.equalTo(self.snp_center)
        }
    }
    
    private func initUIData() {
        currentTimeLabel.text = "00:00"
        totalTimeLabel.text = "00:00"
        
        fullScreenButton.setImage(UIImage(named: BMResourcePath("BMPlayer_fullscreen")), forState: UIControlState.Normal)
        
        loadIndector.hidesWhenStopped = true
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        
        timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), forControlEvents: UIControlEvents.TouchDown)
        timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), forControlEvents: [UIControlEvents.TouchUpInside,UIControlEvents.TouchCancel, UIControlEvents.TouchUpOutside])
    }
}

extension BMPlayer: BMPlayerLayerViewDelegate {
    
    func bmPlayer(player player: BMPlayerLayerView ,loadedTimeDidChange  loadedDuration: Int , totalDuration: Int) {
        print("loadedTimeDidChange - \(loadedDuration) - \(totalDuration)")
    }
    
    func bmPlayer(player player: BMPlayerLayerView, playerStateDidChange state: BMPlayerState) {
        print("playerStateDidChange - \(state)")
        switch state {
        case BMPlayerState.ReadyToPlay:
            loadIndector.stopAnimating()
        case BMPlayerState.Buffering:
            loadIndector.startAnimating()
        case BMPlayerState.BufferFinished:
            loadIndector.stopAnimating()
        case BMPlayerState.Playing:
            loadIndector.stopAnimating()
        default:
            break
        }
    }
    
    func bmPlayer(player player: BMPlayerLayerView, playTimeDidChange currentTime: Int, totalTime: Int) {
        print("playTimeDidChange - \(currentTime) - \(totalTime)")
        currentTimeLabel.text = formatSecondsToString(currentTime)
        totalTimeLabel.text = formatSecondsToString(totalTime)
        
        timeSlider.value    = Float(currentTime) / Float(totalTime)
    }
}