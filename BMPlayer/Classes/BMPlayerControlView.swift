//
//  BMPlayerControlView.swift
//  Pods
//
//  Created by BrikerMan on 16/4/29.
//
//

import UIKit
import NVActivityIndicatorView

protocol BMPlayerControlViewDelegate: class {
    func controlViewDidChooseDefition(index: Int)
}

class BMPlayerControlView: UIView {
    
    weak var delegate: BMPlayerControlViewDelegate?
    /// 主体
    var mainMaskView    = UIView()
    var topMaskView     = UIView()
    var bottomMaskView  = UIView()
    var maskImageView   = UIImageView()
    
    /// 顶部
    var backButton  = UIButton(type: UIButtonType.Custom)
    var titleLabel  = UILabel()
    var chooseDefitionView = UIView()
    
    /// 底部
    var currentTimeLabel = UILabel()
    var totalTimeLabel   = UILabel()
    var timeSlider       = BMTimeSlider()
    var progressView     = UIProgressView()
    var playButton       = UIButton(type: UIButtonType.Custom)
    var fullScreenButton = UIButton(type: UIButtonType.Custom)
    var slowButton       = UIButton(type: UIButtonType.Custom)
    var mirrorButton     = UIButton(type: UIButtonType.Custom)
    
    
    
    /// 中间部分
    var loadingIndector  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))
    
    var seekToView       = UIView()
    var seekToViewImage  = UIImageView()
    var seekToLabel      = UILabel()
    
    var centerButton     = UIButton(type: UIButtonType.Custom)
    
    var videoItems:[BMPlayerItemDefinitionProtocol] = []
    
    var selectedIndex = 0
    
    private var isSelectecDefitionViewOpened = false
    
    var isFullScreen = false {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - funcitons
    func showPlayerIcons() {
        topMaskView.alpha    = 1.0
        bottomMaskView.alpha = 1.0
        mainMaskView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4 )
        
        if isFullScreen {
            chooseDefitionView.alpha = 1.0
        }
    }
    
    func hidePlayerIcons() {
        centerButton.hidden = true
        topMaskView.alpha    = 0.0
        bottomMaskView.alpha = 0.0
        mainMaskView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0 )
        
        chooseDefitionView.snp_updateConstraints { (make) in
            make.height.equalTo(35)
        }
        chooseDefitionView.alpha = 0.0
    }
    
    func updateUI() {
        if isFullScreen {
            if BMPlayerConf.slowAndMirror {
                self.slowButton.hidden = false
                self.mirrorButton.hidden = false

                fullScreenButton.snp_remakeConstraints { (make) in
                    make.width.equalTo(50)
                    make.height.equalTo(50)
                    make.centerY.equalTo(currentTimeLabel)
                    make.left.equalTo(slowButton.snp_right)
                    make.right.equalTo(bottomMaskView.snp_right)
                }
            }
            fullScreenButton.setImage(BMImageResourcePath("BMPlayer_portialscreen"), forState: UIControlState.Normal)
            chooseDefitionView.hidden = false
            if BMPlayerConf.topBarShowInCase.rawValue == 2 {
                topMaskView.hidden = true
            } else {
                topMaskView.hidden = false
            }
        } else {
            if BMPlayerConf.topBarShowInCase.rawValue >= 1 {
                topMaskView.hidden = true
            } else {
                topMaskView.hidden = false
            }
            chooseDefitionView.hidden = true
            
            self.slowButton.hidden = true
            self.mirrorButton.hidden = true
            fullScreenButton.setImage(BMImageResourcePath("BMPlayer_fullscreen"), forState: UIControlState.Normal)
            fullScreenButton.snp_remakeConstraints { (make) in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.centerY.equalTo(currentTimeLabel)
                make.left.equalTo(totalTimeLabel.snp_right)
                make.right.equalTo(bottomMaskView.snp_right)
            }
        }
    }
    
    func showVideoEndedView() {
        centerButton.hidden = false
    }
    
    func showLoader() {
        loadingIndector.hidden = false
        loadingIndector.startAnimation()
    }
    
    func hideLoader() {
        loadingIndector.hidden = true
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
    
    func showCoverWithLink(cover:String) {
        if let url = NSURL(string: cover) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url) //make sure your image in this url does exist, otherwise unwrap in a if let check
                dispatch_async(dispatch_get_main_queue(), {
                    self.maskImageView.image = UIImage(data: data!)
                    self.hideLoader()
                });
            }
        }
    }
    
    func hideImageView() {
        self.maskImageView.hidden = true
    }
    
    func prepareChooseDefinitionView(items:[BMPlayerItemDefinitionProtocol], index: Int) {
        self.videoItems = items
        for item in chooseDefitionView.subviews {
            item.removeFromSuperview()
        }
        
        for i in 0..<items.count {
            let button = BMPlayerClearityChooseButton()
            
            if i == 0 {
                button.tag = index
            } else if i <= index {
                button.tag = i - 1
            } else {
                button.tag = i
            }
            
            button.setTitle("\(items[button.tag].definitionName)", forState: UIControlState.Normal)
            chooseDefitionView.addSubview(button)
            button.addTarget(self, action: #selector(self.onDefinitionSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(chooseDefitionView.snp_top).offset(35 * i)
                make.width.equalTo(50)
                make.height.equalTo(25)
                make.centerX.equalTo(chooseDefitionView)
            })
            
            if items.count == 1 {
                button.enabled = false
            }
        }
    }
    
    @objc private func onDefinitionSelected(button:UIButton) {
        let height = isSelectecDefitionViewOpened ? 35 : videoItems.count * 40
        chooseDefitionView.snp_updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        UIView.animateWithDuration(0.3) {
            self.layoutIfNeeded()
        }
        isSelectecDefitionViewOpened = !isSelectecDefitionViewOpened
        if selectedIndex != button.tag {
            selectedIndex = button.tag
            delegate?.controlViewDidChooseDefition(button.tag)
        }
        prepareChooseDefinitionView(videoItems, index: selectedIndex)
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
        mainMaskView.insertSubview(maskImageView, atIndex: 0)
        
        mainMaskView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4 )
        // 顶部
        topMaskView.addSubview(backButton)
        topMaskView.addSubview(titleLabel)
        self.addSubview(chooseDefitionView)
        
        backButton.setImage(BMImageResourcePath("BMPlayer_back"), forState: UIControlState.Normal)
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text      = "Hello World"
        titleLabel.font      = UIFont.systemFontOfSize(16)
        
        chooseDefitionView.clipsToBounds = true
        
        // 底部
        bottomMaskView.addSubview(playButton)
        bottomMaskView.addSubview(currentTimeLabel)
        bottomMaskView.addSubview(totalTimeLabel)
        bottomMaskView.addSubview(progressView)
        bottomMaskView.addSubview(timeSlider)
        bottomMaskView.addSubview(fullScreenButton)
        bottomMaskView.addSubview(mirrorButton)
        bottomMaskView.addSubview(slowButton)
        
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
        
        mirrorButton.layer.borderWidth = 1
        mirrorButton.layer.borderColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0).CGColor
        mirrorButton.layer.cornerRadius = 2.0
        mirrorButton.setTitle("镜像", forState: UIControlState.Normal)
        mirrorButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        mirrorButton.hidden = true
        
        slowButton.layer.borderWidth = 1
        slowButton.layer.borderColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0).CGColor
        slowButton.layer.cornerRadius = 2.0
        slowButton.setTitle("慢放", forState: UIControlState.Normal)
        slowButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        mirrorButton.hidden = true
        
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
        centerButton.hidden = true
        centerButton.setImage(BMImageResourcePath("BMPlayer_replay"), forState: UIControlState.Normal)
    }
    
    private func addSnapKitConstraint() {
        // 主体
        mainMaskView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        maskImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(mainMaskView)
        }
        
        
        topMaskView.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(mainMaskView)
            make.height.equalTo(65)
        }
        
        bottomMaskView.snp_makeConstraints { (make) in
            make.bottom.left.right.equalTo(mainMaskView)
            make.height.equalTo(50)
        }
        
        // 顶部
        backButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.left.bottom.equalTo(topMaskView)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(backButton.snp_right)
            make.centerY.equalTo(backButton)
        }
        
        chooseDefitionView.snp_makeConstraints { (make) in
            make.right.equalTo(topMaskView.snp_right).offset(-10)
            make.top.equalTo(titleLabel.snp_top).offset(-4)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        
        // 底部
        playButton.snp_makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.left.bottom.equalTo(bottomMaskView)
        }
        
        currentTimeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(playButton.snp_right)
            make.centerY.equalTo(playButton)
            make.width.equalTo(40)
        }
        
        timeSlider.snp_makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(currentTimeLabel.snp_right).offset(10).priority(750)
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
        
        mirrorButton.snp_makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.left.equalTo(totalTimeLabel.snp_right).offset(10)
            make.centerY.equalTo(currentTimeLabel)
        }
        
        slowButton.snp_makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.left.equalTo(mirrorButton.snp_right).offset(10)
            make.centerY.equalTo(currentTimeLabel)
        }
        
        fullScreenButton.snp_makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
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
        
        centerButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(mainMaskView.snp_centerX)
            make.centerY.equalTo(mainMaskView.snp_centerY)
            make.width.height.equalTo(50)
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
