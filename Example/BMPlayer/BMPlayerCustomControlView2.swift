//
//  BMPlayerCustomControlView2.swift
//  BMPlayer
//
//  Created by BrikerMan on 2017/4/6.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import BMPlayer

class BMPlayerCustomControlView2: BMPlayerControlView {
    
    var playTimeUIProgressView = UIProgressView()
    var playingStateLabel = UILabel()
    
    /**
     Override if need to customize UI components
     */
    override func customizeUIComponents() {
        // just make the view hidden
        topMaskView.isHidden = true
        chooseDefinitionView.isHidden = true
        
        // or remove from superview
        playButton.removeFromSuperview()
        currentTimeLabel.removeFromSuperview()
        totalTimeLabel.removeFromSuperview()
        
        timeSlider.removeFromSuperview()
        fullscreenButton.removeFromSuperview()
        
        // If needs to change position remake the constraint
        progressView.snp.remakeConstraints { (make) in
            make.bottom.left.right.equalTo(bottomMaskView)
            make.height.equalTo(2)
        }
        
        // Add new items and constraint
        bottomMaskView.addSubview(playTimeUIProgressView)
        playTimeUIProgressView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(bottomMaskView)
            make.height.equalTo(2)
        }
        
        playTimeUIProgressView.tintColor      = UIColor.red
        playTimeUIProgressView.trackTintColor = UIColor.clear

        addSubview(playingStateLabel)
        playingStateLabel.snp.makeConstraints {
            $0.left.equalTo(self).offset(10)
            $0.bottom.equalTo(self).offset(-10)
        }
        playingStateLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        playingStateLabel.textColor = UIColor.white
    }
    
    override func updateUI(_ isForFullScreen: Bool) {
        topMaskView.isHidden = true
        chooseDefinitionView.isHidden = true
    }
    
    override func playTimeDidChange(currentTime: TimeInterval, totalTime: TimeInterval) {
        playTimeUIProgressView.setProgress(Float(currentTime/totalTime), animated: true)
    }

    override func onTapGestureTapped(_ gesture: UITapGestureRecognizer) {
        // redirect tap action to play button action
        delegate?.controlView(controlView: self, didPressButton: playButton)
    }
    
    override func playStateDidChange(isPlaying: Bool) {
        super.playStateDidChange(isPlaying: isPlaying)
        playingStateLabel.text = isPlaying ? "Playing" : "Paused"
    }
    
    override func controlViewAnimation(isShow: Bool) {
        
    }
}
