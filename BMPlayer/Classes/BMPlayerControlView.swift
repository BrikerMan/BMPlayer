//
//  BMPlayerControlView.swift
//  Pods
//
//  Created by BrikerMan on 16/4/29.
//
//

import UIKit
import NVActivityIndicatorView

class BMPlayerControlView: UIView {
    /// 主体
    var mainMaskView    = UIView()
    var topMaskView     = UIView()
    var bottomMaskView  = UIView()
    
    /// 顶部
    var backButton  = UIButton(type: UIButtonType.Custom)
    var titleLabel  = UILabel()
    
    /// 底部
    var currentTimeLabel = UILabel()
    var totalTimeLabel   = UILabel()
    var timeSlider       = BMTimeSlider()
    var progressView     = UIProgressView()
    var playButton       = UIButton(type: UIButtonType.Custom)
    var fullScreenButton = UIButton(type: UIButtonType.Custom)
    
    /// 中间部分
    var loadingIndector  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))
    
    var seekToView       = UIView()
    var seekToViewImage  = UIImageView()
    var seekToLabel      = UILabel()
    
    var centerButton     = UIButton(type: UIButtonType.Custom)
    
    // MARK: - funcitons
    func showPlayerIcons() {
        topMaskView.alpha    = 1.0
        bottomMaskView.alpha = 1.0
        mainMaskView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3 )
    }
    
    func hidePlayerIcons() {
        centerButton.hidden = true
        topMaskView.alpha    = 0.0
        bottomMaskView.alpha = 0.0
        mainMaskView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0 )
    }
    
    func showVideoEndedView() {
        centerButton.hidden = false
    }
    
    func showLoader() {
        loadingIndector.startAnimation()
    }
    
    func hideLoader() {
        loadingIndector.stopAnimation()
    }
    
    func showSeekToView(to: String, isAdd: Bool) {
        seekToView.hidden   = false
        seekToLabel.text    = to
        let rotate = isAdd ? 0 : CGFloat(M_PI)
        seekToViewImage.transform = CGAffineTransformMakeRotation(rotate)
    }
    
    func hideSeekToView() {
        seekToView.hidden = true
    }
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        addSnapKitConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        addSnapKitConstraint()
        
    }
    
    private func initUI() {
        // 主体
        addSubview(mainMaskView)
        mainMaskView.addSubview(topMaskView)
        mainMaskView.addSubview(bottomMaskView)
        
        // 顶部
        topMaskView.addSubview(backButton)
        topMaskView.addSubview(titleLabel)
        
        backButton.setImage(BMImageResourcePath("BMPlayer_back"), forState: UIControlState.Normal)
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text      = "Hello World"
        titleLabel.font      = UIFont.systemFontOfSize(16)
        
        bottomMaskView.addSubview(playButton)
        bottomMaskView.addSubview(currentTimeLabel)
        bottomMaskView.addSubview(totalTimeLabel)
        bottomMaskView.addSubview(progressView)
        bottomMaskView.addSubview(timeSlider)
        bottomMaskView.addSubview(fullScreenButton)
        
        playButton.setImage(BMImageResourcePath("BMPlayer_play"), forState: UIControlState.Normal)
        playButton.setImage(BMImageResourcePath("BMPlayer_pause"), forState: UIControlState.Selected)
        
        currentTimeLabel.textColor  = UIColor.whiteColor()
        currentTimeLabel.font       = UIFont.systemFontOfSize(12)
        currentTimeLabel.text       = "00:00"
        currentTimeLabel.textAlignment = NSTextAlignment.Center
        
        totalTimeLabel.textColor    = UIColor.whiteColor()
        totalTimeLabel.font         = UIFont.systemFontOfSize(12)
        totalTimeLabel.text         = "00:00"
        totalTimeLabel.textAlignment   = NSTextAlignment.Center
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        timeSlider.setThumbImage(BMImageResourcePath("BMPlayer_slider_thumb"), forState: UIControlState.Normal)
        
        timeSlider.maximumTrackTintColor = UIColor.clearColor()
        timeSlider.minimumTrackTintColor = BMPlayerConf.tintColor
        
        progressView.tintColor      = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6 )
        progressView.trackTintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3 )
        
        fullScreenButton.setImage(BMImageResourcePath("BMPlayer_fullscreen"), forState: UIControlState.Normal)
        
        // 中间
        mainMaskView.addSubview(loadingIndector)
        
        loadingIndector.hidesWhenStopped = true
        loadingIndector.type             = BMPlayerConf.loaderType
        loadingIndector.color            = BMPlayerConf.tintColor
        
        
        // 滑动时间显示
        addSubview(seekToView)
        seekToView.addSubview(seekToViewImage)
        seekToView.addSubview(seekToLabel)
        
        seekToLabel.font                = UIFont.systemFontOfSize(13)
        seekToLabel.textColor           = UIColor ( red: 0.9098, green: 0.9098, blue: 0.9098, alpha: 1.0 )
        seekToView.backgroundColor      = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7 )
        seekToView.layer.cornerRadius   = 4
        seekToView.layer.masksToBounds  = true
        seekToView.hidden               = true
        
        seekToViewImage.image = BMImageResourcePath("BMPlayer_seek_to_image")
        
        self.addSubview(centerButton)
        
        
        
        
    }
    
    private func addSnapKitConstraint() {
        // 主体
        mainMaskView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        topMaskView.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(mainMaskView)
            make.height.equalTo(60)
        }
        
        bottomMaskView.snp_makeConstraints { (make) in
            make.bottom.left.right.equalTo(mainMaskView)
            make.height.equalTo(40)
        }
        
        // 顶部
        backButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.bottom.equalTo(topMaskView)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(backButton.snp_right).offset(5)
            make.centerY.equalTo(backButton)
        }
        
        // 底部
        playButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.bottom.equalTo(bottomMaskView)
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
            make.right.equalTo(bottomMaskView.snp_right)
        }
        
        // 中间
        loadingIndector.snp_makeConstraints { (make) in
            make.centerX.equalTo(mainMaskView.snp_centerX).offset(-15)
            make.centerY.equalTo(mainMaskView.snp_centerY).offset(-15)
        }
        
        seekToView.snp_makeConstraints { (make) in
            make.center.equalTo(self.snp_center)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        seekToViewImage.snp_makeConstraints { (make) in
            make.left.equalTo(seekToView.snp_left).offset(15)
            make.centerY.equalTo(seekToView.snp_centerY)
            make.height.equalTo(15)
            make.width.equalTo(25)
        }
        
        seekToLabel.snp_makeConstraints { (make) in
            make.left.equalTo(seekToViewImage.snp_right).offset(10)
            make.centerY.equalTo(seekToView.snp_centerY)
        }
        
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

public class BMTimeSlider: UISlider {
    override public func trackRectForBounds(bounds: CGRect) -> CGRect {
        let trackHeigt:CGFloat = 2
        let position = CGPoint(x: 0 , y: 14)
        let customBounds = CGRect(origin: position, size: CGSize(width: bounds.size.width, height: trackHeigt))
        super.trackRectForBounds(customBounds)
        return customBounds
    }
    
    override public func thumbRectForBounds(bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRectForBounds(bounds, trackRect: rect, value: value)
        let newx = rect.origin.x - 10
        let newRect = CGRectMake(newx, 0, 30, 30)
        return newRect
    }
}
