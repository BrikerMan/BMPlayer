//
//  BMPlayerCustomControlView.swift
//  BMPlayer
//
//  Created by BrikerMan on 2017/4/4.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import BMPlayer

class BMPlayerCustomControlView: BMPlayerControlView {
    
    var playbackRateButton = UIButton(type: .custom)
    var playRate: Float = 1.0
    
    var rotateButton = UIButton(type: .custom)
    var rotateCount: CGFloat = 0
    
    /**
     Override if need to customize UI components
     */
    override func customizeUIComponents() {
        mainMaskView.backgroundColor   = UIColor.clear
        topMaskView.backgroundColor    = UIColor.black.withAlphaComponent(0.4)
        bottomMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        timeSlider.setThumbImage(UIImage(named: "custom_slider_thumb"), for: .normal)
        
        topMaskView.addSubview(playbackRateButton)
        
        playbackRateButton.layer.cornerRadius = 2
        playbackRateButton.layer.borderWidth  = 1
        playbackRateButton.layer.borderColor  = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8 ).cgColor
        playbackRateButton.setTitleColor(UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9 ), for: .normal)
        playbackRateButton.setTitle("  rate \(playRate)  ", for: .normal)
        playbackRateButton.addTarget(self, action: #selector(onPlaybackRateButtonPressed), for: .touchUpInside)
        playbackRateButton.titleLabel?.font   = UIFont.systemFont(ofSize: 12)
        playbackRateButton.isHidden = true
        playbackRateButton.snp.makeConstraints {
            $0.right.equalTo(chooseDefinitionView.snp.left).offset(-5)
            $0.centerY.equalTo(chooseDefinitionView)
        }
        
        topMaskView.addSubview(rotateButton)
        rotateButton.layer.cornerRadius = 2
        rotateButton.layer.borderWidth  = 1
        rotateButton.layer.borderColor  = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8 ).cgColor
        rotateButton.setTitleColor(UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9 ), for: .normal)
        rotateButton.setTitle("  rotate  ", for: .normal)
        rotateButton.addTarget(self, action: #selector(onRotateButtonPressed), for: .touchUpInside)
        rotateButton.titleLabel?.font   = UIFont.systemFont(ofSize: 12)
        rotateButton.isHidden = true
        rotateButton.snp.makeConstraints {
            $0.right.equalTo(playbackRateButton.snp.left).offset(-5)
            $0.centerY.equalTo(chooseDefinitionView)
        }
    }
    
    
    
    override func updateUI(_ isForFullScreen: Bool) {
        super.updateUI(isForFullScreen)
        playbackRateButton.isHidden = !isForFullScreen
        rotateButton.isHidden = !isForFullScreen
        if let layer = player?.playerLayer {
            layer.frame = player!.bounds
        }
    }
    
    override func controlViewAnimation(isShow: Bool) {
        self.isMaskShowing = isShow
        UIApplication.shared.setStatusBarHidden(!isShow, with: .fade)
        
        UIView.animate(withDuration: 0.24, animations: {
            self.topMaskView.snp.remakeConstraints {
                $0.top.equalTo(self.mainMaskView).offset(isShow ? 0 : -65)
                $0.left.right.equalTo(self.mainMaskView)
                $0.height.equalTo(65)
            }
            
            self.bottomMaskView.snp.remakeConstraints {
                $0.bottom.equalTo(self.mainMaskView).offset(isShow ? 0 : 50)
                $0.left.right.equalTo(self.mainMaskView)
                $0.height.equalTo(50)
            }
            self.layoutIfNeeded()
        }) { (_) in
            self.autoFadeOutControlViewWithAnimation()
        }
    }
    
    @objc func onPlaybackRateButtonPressed() {
        autoFadeOutControlViewWithAnimation()
        switch playRate {
        case 1.0:
            playRate = 1.5
        case 1.5:
            playRate = 0.5
        case 0.5:
            playRate = 1.0
        default:
            playRate = 1.0
        }
        playbackRateButton.setTitle("  rate \(playRate)  ", for: .normal)
        delegate?.controlView?(controlView: self, didChangeVideoPlaybackRate: playRate)
    }
    
    
    
    @objc func onRotateButtonPressed() {
        guard let layer = player?.playerLayer else {
            return
        }
        print("rotated")
        rotateCount += 1
        layer.transform = CGAffineTransform(rotationAngle: rotateCount * CGFloat(Double.pi/2))
        layer.frame = player!.bounds
    }
}
