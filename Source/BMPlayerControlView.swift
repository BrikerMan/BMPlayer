//
//  BMPlayerControlView.swift
//  Pods
//
//  Created by BrikerMan on 16/4/29.
//
//

import UIKit
import NVActivityIndicatorView


@objc public protocol BMPlayerControlViewDelegate: class {
    /**
     call when control view choose a definition
     
     - parameter controlView: control view
     - parameter index:       index of definition
     */
    func controlView(controlView: BMPlayerControlView, didChooseDefition index: Int)
    
    /**
     call when control view pressed an button
     
     - parameter controlView: control view
     - parameter button:      button type
     */
    func controlView(controlView: BMPlayerControlView, didPressButton button: UIButton)
    
    /**
     call when slider action trigged
     
     - parameter controlView: control view
     - parameter slider:      progress slider
     - parameter event:       action
     */
    func controlView(controlView: BMPlayerControlView, slider: UISlider, onSliderEvent event: UIControlEvents)
    
    /**
     call when needs to change playback rate
     
     - parameter controlView: control view
     - parameter rate:        playback rate
     */
    @objc optional func controlView(controlView: BMPlayerControlView, didChangeVideoPlaybackRate rate: Float)
}

open class BMPlayerControlView: UIView {
    
    open weak var delegate: BMPlayerControlViewDelegate?
    open weak var player: BMPlayer?
    
    // MARK: Variables
    open var resource: BMPlayerResource?
    
    open var selectedIndex = 0
    open var isFullscreen  = false
    open var isMaskShowing = true
    
    open var totalDuration:TimeInterval = 0
    open var delayItem: DispatchWorkItem?
    
    var playerLastState: BMPlayerState = .notSetURL
    
    fileprivate var isSelectecDefitionViewOpened = false
    
    // MARK: UI Components
    /// main views which contains the topMaskView and bottom mask view
    open var mainMaskView    = UIView()
    open var topMaskView     = UIView()
    open var bottomMaskView  = UIView()
    
    /// Image view to show video cover
    open var maskImageView   = UIImageView()
    
    /// top views
    open var backButton         = UIButton(type : UIButtonType.custom)
    open var titleLabel         = UILabel()
    open var chooseDefitionView = UIView()
    
    /// bottom view
    open var currentTimeLabel = UILabel()
    open var totalTimeLabel   = UILabel()
    
    /// Progress slider
    open var timeSlider       = BMTimeSlider()
    
    /// load progress view
    open var progressView     = UIProgressView()
    
    /* play button
     playButton.isSelected = player.isPlaying
     */
    open var playButton       = UIButton(type: UIButtonType.custom)
    
    /* fullScreen button
     fullScreenButton.isSelected = player.isFullscreen
     */
    open var fullscreenButton = UIButton(type: UIButtonType.custom)
    
    open var subtitleLabel    = UILabel()
    open var subtitleBackView = UIView()
    open var subtileAttrabute: [NSAttributedStringKey : Any]?
    
    /// Activty Indector for loading
    open var loadingIndector  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))
    
    open var seekToView       = UIView()
    open var seekToViewImage  = UIImageView()
    open var seekToLabel      = UILabel()
    
    open var replayButton     = UIButton(type: UIButtonType.custom)
    
    /// Gesture used to show / hide control view
    open var tapGesture: UITapGestureRecognizer!
    
    // MARK: - handle player state change
    /**
     call on when play time changed, update duration here
     
     - parameter currentTime: current play time
     - parameter totalTime:   total duration
     */
    open func playTimeDidChange(currentTime: TimeInterval, totalTime: TimeInterval) {
        currentTimeLabel.text = BMPlayer.formatSecondsToString(currentTime)
        totalTimeLabel.text   = BMPlayer.formatSecondsToString(totalTime)
        timeSlider.value      = Float(currentTime) / Float(totalTime)
        if let subtitle = resource?.subtitle {
            showSubtile(from: subtitle, at: currentTime)
        }
    }
    
    /**
     call on load duration changed, update load progressView here
     
     - parameter loadedDuration: loaded duration
     - parameter totalDuration:  total duration
     */
    open func loadedTimeDidChange(loadedDuration: TimeInterval , totalDuration: TimeInterval) {
        progressView.setProgress(Float(loadedDuration)/Float(totalDuration), animated: true)
    }
    
    open func playerStateDidChange(state: BMPlayerState) {
        switch state {
        case .readyToPlay:
            hideLoader()
            
        case .buffering:
            showLoader()
            
        case .bufferFinished:
            hideLoader()
            
        case .playedToTheEnd:
            playButton.isSelected = false
            showPlayToTheEndView()
            controlViewAnimation(isShow: true)
            cancelAutoFadeOutAnimation()
            
        default:
            break
        }
        playerLastState = state
    }
    
    /**
     Call when User use the slide to seek function
     
     - parameter toSecound:     target time
     - parameter totalDuration: total duration of the video
     - parameter isAdd:         isAdd
     */
    open func showSeekToView(to toSecound: TimeInterval, total totalDuration:TimeInterval, isAdd: Bool) {
        seekToView.isHidden   = false
        seekToLabel.text    = BMPlayer.formatSecondsToString(toSecound)
        
        let rotate = isAdd ? 0 : CGFloat(Double.pi)
        seekToViewImage.transform = CGAffineTransform(rotationAngle: rotate)
        
        let targetTime      = BMPlayer.formatSecondsToString(toSecound)
        timeSlider.value      = Float(toSecound / totalDuration)
        currentTimeLabel.text = targetTime
    }
    
    // MARK: - UI update related function
    /**
     Update UI details when player set with the resource
     
     - parameter resource: video resouce
     - parameter index:    defualt definition's index
     */
    open func prepareUI(for resource: BMPlayerResource, selectedIndex index: Int) {
        self.resource = resource
        self.selectedIndex = index
        titleLabel.text = resource.name
        prepareChooseDefinitionView()
        autoFadeOutControlViewWithAnimation()
    }
    
    open func playStateDidChange(isPlaying: Bool) {
        autoFadeOutControlViewWithAnimation()
        playButton.isSelected = isPlaying
    }
    
    /**
     auto fade out controll view with animtion
     */
    open func autoFadeOutControlViewWithAnimation() {
        cancelAutoFadeOutAnimation()
        delayItem = DispatchWorkItem { [weak self] in
            self?.controlViewAnimation(isShow: false)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + BMPlayerConf.animateDelayTimeInterval,
                                      execute: delayItem!)
    }
    
    /**
     cancel auto fade out controll view with animtion
     */
    open func cancelAutoFadeOutAnimation() {
        delayItem?.cancel()
    }
    
    /**
     Implement of the control view animation, override if need's custom animation
     
     - parameter isShow: is to show the controlview
     */
    open func controlViewAnimation(isShow: Bool) {
        let alpha: CGFloat = isShow ? 1.0 : 0.0
        self.isMaskShowing = isShow
        
        UIApplication.shared.setStatusBarHidden(!isShow, with: .fade)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.topMaskView.alpha    = alpha
            self.bottomMaskView.alpha = alpha
            self.mainMaskView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: isShow ? 0.4 : 0.0)
            
            if isShow {
                if self.isFullscreen { self.chooseDefitionView.alpha = 1.0 }
            } else {
                self.replayButton.isHidden = true
                self.chooseDefitionView.snp.updateConstraints { (make) in
                    make.height.equalTo(35)
                }
                self.chooseDefitionView.alpha = 0.0
            }
            self.layoutIfNeeded()
        }) { (_) in
            if isShow {
                self.autoFadeOutControlViewWithAnimation()
            }
        }
    }
    
    /**
     Implement of the UI update when screen orient changed
     
     - parameter isForFullScreen: is for full screen
     */
    open func updateUI(_ isForFullScreen: Bool) {
        isFullscreen = isForFullScreen
        fullscreenButton.isSelected = isForFullScreen
        chooseDefitionView.isHidden = !isForFullScreen
        if isForFullScreen {
            if BMPlayerConf.topBarShowInCase.rawValue == 2 {
                topMaskView.isHidden = true
            } else {
                topMaskView.isHidden = false
            }
        } else {
            if BMPlayerConf.topBarShowInCase.rawValue >= 1 {
                topMaskView.isHidden = true
            } else {
                topMaskView.isHidden = false
            }
        }
    }
    
    /**
     Call when video play's to the end, override if you need custom UI or animation when played to the end
     */
    open func showPlayToTheEndView() {
        replayButton.isHidden = false
    }
    
    open func hidePlayToTheEndView() {
        replayButton.isHidden = true
    }
    
    open func showLoader() {
        loadingIndector.isHidden = false
        loadingIndector.startAnimating()
    }
    
    open func hideLoader() {
        loadingIndector.isHidden = true
    }
    
    open func hideSeekToView() {
        seekToView.isHidden = true
    }
    
    open func showCoverWithLink(_ cover:String) {
        self.showCover(url: URL(string: cover))
    }
    
    open func showCover(url: URL?) {
        if let url = url {
            DispatchQueue.global(qos: .default).async {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async(execute: {
                    if let data = data {
                        self.maskImageView.image = UIImage(data: data)
                    } else {
                        self.maskImageView.image = nil
                    }
                    self.hideLoader()
                });
            }
        }
    }
    
    open func hideCoverImageView() {
        self.maskImageView.isHidden = true
    }
    
    open func prepareChooseDefinitionView() {
        guard let resource = resource else {
            return
        }
        for item in chooseDefitionView.subviews {
            item.removeFromSuperview()
        }
        
        for i in 0..<resource.definitions.count {
            let button = BMPlayerClearityChooseButton()
            
            if i == 0 {
                button.tag = selectedIndex
            } else if i <= selectedIndex {
                button.tag = i - 1
            } else {
                button.tag = i
            }
            
            button.setTitle("\(resource.definitions[button.tag].definition)", for: UIControlState())
            chooseDefitionView.addSubview(button)
            button.addTarget(self, action: #selector(self.onDefinitionSelected(_:)), for: UIControlEvents.touchUpInside)
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(chooseDefitionView.snp.top).offset(35 * i)
                make.width.equalTo(50)
                make.height.equalTo(25)
                make.centerX.equalTo(chooseDefitionView)
            })
            
            if resource.definitions.count == 1 {
                button.isEnabled = false
            }
        }
    }
    
    open func prepareToDealloc() {
        self.delayItem = nil
    }
    
    // MARK: - Action Response
    /**
     Call when some action button Pressed
     
     - parameter button: action Button
     */
    @objc open func onButtonPressed(_ button: UIButton) {
        autoFadeOutControlViewWithAnimation()
        if let type = ButtonType(rawValue: button.tag) {
            switch type {
            case .play, .replay:
                if playerLastState == .playedToTheEnd {
                    hidePlayToTheEndView()
                }
            default:
                break
            }
        }
        delegate?.controlView(controlView: self, didPressButton: button)
    }
    
    /**
     Call when the tap gesture tapped
     
     - parameter gesture: tap gesture
     */
    @objc open func onTapGestureTapped(_ gesture: UITapGestureRecognizer) {
        if playerLastState == .playedToTheEnd {
            return
        }
        controlViewAnimation(isShow: !isMaskShowing)
    }
    
    
    
    // MARK: - handle UI slider actions
    @objc func progressSliderTouchBegan(_ sender: UISlider)  {
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchDown)
    }
    
    @objc func progressSliderValueChanged(_ sender: UISlider)  {
        hidePlayToTheEndView()
        cancelAutoFadeOutAnimation()
        let currentTime = Double(sender.value) * totalDuration
        currentTimeLabel.text = BMPlayer.formatSecondsToString(currentTime)
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .valueChanged)
    }
    
    @objc func progressSliderTouchEnded(_ sender: UISlider)  {
        autoFadeOutControlViewWithAnimation()
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchUpInside)
    }
    
    
    // MARK: - private functions
    fileprivate func showSubtile(from subtitle: BMSubtitles, at time: TimeInterval) {
        if let group = subtitle.search(for: time) {
            subtitleBackView.isHidden = false
            subtitleLabel.attributedText = NSAttributedString(string: group.text,
                                                              attributes: subtileAttrabute)
        } else {
            subtitleBackView.isHidden = true
        }
    }
    
    @objc fileprivate func onDefinitionSelected(_ button:UIButton) {
        let height = isSelectecDefitionViewOpened ? 35 : resource!.definitions.count * 40
        chooseDefitionView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
        isSelectecDefitionViewOpened = !isSelectecDefitionViewOpened
        if selectedIndex != button.tag {
            selectedIndex = button.tag
            delegate?.controlView(controlView: self, didChooseDefition: button.tag)
        }
        prepareChooseDefinitionView()
    }
    
    @objc fileprivate func onReplyButtonPressed() {
        replayButton.isHidden = true
    }
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUIComponents()
        addSnapKitConstraint()
        customizeUIComponents()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUIComponents()
        addSnapKitConstraint()
        customizeUIComponents()
    }
    
    /// Add Customize functions here
    open func customizeUIComponents() {
        
    }
    
    func setupUIComponents() {
        // Subtile view
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        
        subtitleBackView.layer.cornerRadius = 2
        subtitleBackView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        subtitleBackView.addSubview(subtitleLabel)
        subtitleBackView.isHidden = true
        
        addSubview(subtitleBackView)
        
        // Main mask view
        addSubview(mainMaskView)
        mainMaskView.addSubview(topMaskView)
        mainMaskView.addSubview(bottomMaskView)
        mainMaskView.insertSubview(maskImageView, at: 0)
        mainMaskView.clipsToBounds = true
        mainMaskView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4 )
        
        // Top views
        topMaskView.addSubview(backButton)
        topMaskView.addSubview(titleLabel)
        addSubview(chooseDefitionView)
        
        backButton.tag = BMPlayerControlView.ButtonType.back.rawValue
        backButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_back"), for: .normal)
        backButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        titleLabel.textColor = UIColor.white
        titleLabel.text      = ""
        titleLabel.font      = UIFont.systemFont(ofSize: 16)
        
        chooseDefitionView.clipsToBounds = true
        
        // Bottom views
        bottomMaskView.addSubview(playButton)
        bottomMaskView.addSubview(currentTimeLabel)
        bottomMaskView.addSubview(totalTimeLabel)
        bottomMaskView.addSubview(progressView)
        bottomMaskView.addSubview(timeSlider)
        bottomMaskView.addSubview(fullscreenButton)
        
        playButton.tag = BMPlayerControlView.ButtonType.play.rawValue
        playButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_play"),  for: .normal)
        playButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_pause"), for: .selected)
        playButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        currentTimeLabel.textColor  = UIColor.white
        currentTimeLabel.font       = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.text       = "00:00"
        currentTimeLabel.textAlignment = NSTextAlignment.center
        
        totalTimeLabel.textColor    = UIColor.white
        totalTimeLabel.font         = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.text         = "00:00"
        totalTimeLabel.textAlignment   = NSTextAlignment.center
        
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        timeSlider.setThumbImage(BMImageResourcePath("Pod_Asset_BMPlayer_slider_thumb"), for: .normal)
        
        timeSlider.maximumTrackTintColor = UIColor.clear
        timeSlider.minimumTrackTintColor = BMPlayerConf.tintColor
        
        timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)),
                             for: UIControlEvents.touchDown)
        
        timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)),
                             for: UIControlEvents.valueChanged)
        
        timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)),
                             for: [UIControlEvents.touchUpInside,UIControlEvents.touchCancel, UIControlEvents.touchUpOutside])
        
        progressView.tintColor      = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6 )
        progressView.trackTintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3 )
        
        fullscreenButton.tag = BMPlayerControlView.ButtonType.fullscreen.rawValue
        fullscreenButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_fullscreen"),    for: .normal)
        fullscreenButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_portialscreen"), for: .selected)
        fullscreenButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        mainMaskView.addSubview(loadingIndector)
        
        loadingIndector.type             = BMPlayerConf.loaderType
        loadingIndector.color            = BMPlayerConf.tintColor
        
        // View to show when slide to seek
        addSubview(seekToView)
        seekToView.addSubview(seekToViewImage)
        seekToView.addSubview(seekToLabel)
        
        seekToLabel.font                = UIFont.systemFont(ofSize: 13)
        seekToLabel.textColor           = UIColor ( red: 0.9098, green: 0.9098, blue: 0.9098, alpha: 1.0 )
        seekToView.backgroundColor      = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7 )
        seekToView.layer.cornerRadius   = 4
        seekToView.layer.masksToBounds  = true
        seekToView.isHidden               = true
        
        seekToViewImage.image = BMImageResourcePath("Pod_Asset_BMPlayer_seek_to_image")
        
        addSubview(replayButton)
        replayButton.isHidden = true
        replayButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_replay"), for: .normal)
        replayButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        replayButton.tag = ButtonType.replay.rawValue
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGestureTapped(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    func addSnapKitConstraint() {
        // Main mask view
        mainMaskView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        maskImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(mainMaskView)
        }
        
        
        topMaskView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(mainMaskView)
            make.height.equalTo(65)
        }
        
        bottomMaskView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(mainMaskView)
            make.height.equalTo(50)
        }
        
        // Top views
        backButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.left.bottom.equalTo(topMaskView)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right)
            make.centerY.equalTo(backButton)
        }
        
        chooseDefitionView.snp.makeConstraints { (make) in
            make.right.equalTo(topMaskView.snp.right).offset(-20)
            make.top.equalTo(titleLabel.snp.top).offset(-4)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        // Bottom views
        playButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.left.bottom.equalTo(bottomMaskView)
        }
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right)
            make.centerY.equalTo(playButton)
            make.width.equalTo(40)
        }
        
        timeSlider.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(currentTimeLabel.snp.right).offset(10).priority(750)
            make.height.equalTo(30)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.centerY.left.right.equalTo(timeSlider)
            make.height.equalTo(2)
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(timeSlider.snp.right).offset(5)
            make.width.equalTo(40)
        }
        
        fullscreenButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(totalTimeLabel.snp.right)
            make.right.equalTo(bottomMaskView.snp.right)
        }
        
        
        loadingIndector.snp.makeConstraints { (make) in
            make.centerX.equalTo(mainMaskView.snp.centerX).offset(0)
            make.centerY.equalTo(mainMaskView.snp.centerY).offset(0)
        }
        
        // View to show when slide to seek
        seekToView.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        seekToViewImage.snp.makeConstraints { (make) in
            make.left.equalTo(seekToView.snp.left).offset(15)
            make.centerY.equalTo(seekToView.snp.centerY)
            make.height.equalTo(15)
            make.width.equalTo(25)
        }
        
        seekToLabel.snp.makeConstraints { (make) in
            make.left.equalTo(seekToViewImage.snp.right).offset(10)
            make.centerY.equalTo(seekToView.snp.centerY)
        }
        
        replayButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(mainMaskView.snp.centerX)
            make.centerY.equalTo(mainMaskView.snp.centerY)
            make.width.height.equalTo(50)
        }
        
        subtitleBackView.snp.makeConstraints {
            $0.bottom.equalTo(snp.bottom).offset(-5)
            $0.centerX.equalTo(snp.centerX)
            $0.width.lessThanOrEqualTo(snp.width).offset(-10).priority(750)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.left.equalTo(subtitleBackView.snp.left).offset(10)
            $0.right.equalTo(subtitleBackView.snp.right).offset(-10)
            $0.top.equalTo(subtitleBackView.snp.top).offset(2)
            $0.bottom.equalTo(subtitleBackView.snp.bottom).offset(-2)
        }
    }
    
    fileprivate func BMImageResourcePath(_ fileName: String) -> UIImage? {
        let bundle = Bundle(for: BMPlayer.self)
        let image  = UIImage(named: fileName, in: bundle, compatibleWith: nil)
        return image
    }
}

