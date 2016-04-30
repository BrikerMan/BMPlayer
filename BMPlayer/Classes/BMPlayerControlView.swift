//
//  BMPlayerControlView.swift
//  Pods
//
//  Created by BrikerMan on 16/4/29.
//
//

import UIKit

class BMPlayerControlView: UIView, BMPlayerControllViewProtocol {
    var view: UIView {
        get {
            return self
        }
    }
    var maskImageView    = UIImageView()
    
    var currentTimeLabel = UILabel()
    var totalTimeLabel   = UILabel()
    
    var playButton       = UIButton(type: UIButtonType.Custom)
    var timeSlider       = UISlider()
    var progressView     = UIProgressView()
    var fullScreenButton = UIButton(type: UIButtonType.Custom)
    var backButton       = UIButton(type: UIButtonType.Custom)
    
    var loadIndector     = UIActivityIndicatorView()
    var centerLabel      = UILabel()
    
    // MARK: - funcitons
    func showPlayerIcons() {
        maskImageView.alpha = 0.0
    }
    
    func hidePlayerIcons() {
        maskImageView.alpha = 1.0
    }
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initUIData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        initUIData()
    }
    
    private func initUI() {
        addSubview(maskImageView)
        maskImageView.userInteractionEnabled = true
    
        currentTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.textColor   = UIColor.whiteColor()
        currentTimeLabel.font      = UIFont.systemFontOfSize(12)
        totalTimeLabel.font      = UIFont.systemFontOfSize(12)
        
        maskImageView.addSubview(currentTimeLabel)
        maskImageView.addSubview(totalTimeLabel)
        
        maskImageView.addSubview(progressView)
        maskImageView.addSubview(timeSlider)
        maskImageView.addSubview(fullScreenButton)
        maskImageView.addSubview(playButton)
        maskImageView.addSubview(backButton)
        
        addSubview(loadIndector)
        addSubview(centerLabel)
        
        addSnapKitConstraint()
    }
    
    private func addSnapKitConstraint() {
        maskImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        playButton.snp_makeConstraints { (make) in
            make.left.equalTo(self.snp_left).offset(5)
            make.bottom.equalTo(self.snp_bottom)
            make.width.height.equalTo(40)
        }
        
        currentTimeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(playButton.snp_right)
            make.centerY.equalTo(playButton)
            make.width.equalTo(40)
        }
        
        timeSlider.snp_makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(currentTimeLabel.snp_right).offset(10)
            make.height.equalTo(30)
        }
        
        progressView.snp_makeConstraints { (make) in
            make.centerY.left.right.equalTo(timeSlider)
            make.height.equalTo(2)
        }
        
        
        totalTimeLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(timeSlider.snp_right).offset(5)
            make.width.equalTo(40)
        }
        
        fullScreenButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(totalTimeLabel.snp_right)
            make.right.equalTo(self.snp_right)
        }
        
        backButton.snp_makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self).offset(5)
            make.width.height.equalTo(40)
        }
        
        loadIndector.snp_makeConstraints { (make) in
            make.center.equalTo(self.snp_center)
        }
        
        centerLabel.snp_makeConstraints { (make) in
            make.center.equalTo(self.snp_center)
            make.width.equalTo(100)
            make.height.equalTo(24)
        }
    }
    
    private func initUIData() {
        addSubview(maskImageView)
        maskImageView.image = BMImageResourcePath("BMPlayer_mask_image")
        
        currentTimeLabel.text   = "00:00"
        totalTimeLabel.text     = "00:00"
        
        currentTimeLabel.textAlignment = NSTextAlignment.Center
        totalTimeLabel.textAlignment   = NSTextAlignment.Center
        
        playButton.setImage(BMImageResourcePath("BMPlayer_play"), forState: UIControlState.Normal)
        playButton.setImage(BMImageResourcePath("BMPlayer_pause"), forState: UIControlState.Selected)
        
        backButton.setImage(BMImageResourcePath("BMPlayer_back"), forState: UIControlState.Normal)
        fullScreenButton.setImage(BMImageResourcePath("BMPlayer_fullscreen"), forState: UIControlState.Normal)
        
        loadIndector.hidesWhenStopped = true
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        timeSlider.setThumbImage(BMImageResourcePath("BMPlayer_slider_thumb"), forState: UIControlState.Normal)
        
        timeSlider.maximumTrackTintColor = UIColor.clearColor()
        timeSlider.minimumTrackTintColor = UIColor.whiteColor()
        
        progressView.tintColor      = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6 )
        progressView.trackTintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3 )
        
        centerLabel.font = UIFont.systemFontOfSize(12)
        centerLabel.textColor       = UIColor.whiteColor()
        centerLabel.textAlignment   = NSTextAlignment.Center
        centerLabel.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4 )
        centerLabel.layer.cornerRadius = 2
        centerLabel.clipsToBounds      = true
        centerLabel.hidden             = true
        
    }
    
    private func BMImageResourcePath(fileName: String) -> UIImage? {
        let podBundle = NSBundle(forClass: self.classForCoder)
        if let bundleURL = podBundle.URLForResource("BMPlayer", withExtension: "bundle") {
            if let bundle = NSBundle(URL: bundleURL) {
                let image = UIImage(named: fileName, inBundle: bundle, compatibleWithTraitCollection: nil)
                return image
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
        }
        return nil
    }
    
}
