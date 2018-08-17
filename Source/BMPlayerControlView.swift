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
    func controlView(controlView: BMPlayerControlView, didChooseDefinition index: Int)
    
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
    
    open var totalDuration: TimeInterval = 0
    open var delayItem: DispatchWorkItem?
    
    var playerLastState: BMPlayerState = .notSetURL
    
    fileprivate var isSelectDefinitionViewOpened = false
    
    // MARK: UI Components
    /// main views which contains the topMaskView and bottom mask view
    open var mainMaskView   = UIView()
    open var topMaskView    = UIView()
    open var bottomMaskView = UIView()
    
    /// Image view to show video cover
    open var maskImageView = UIImageView()
    
    /// top views

    open var backButton         = UIButton(type : UIButtonType.custom)
    open var titleLabel         = UILabel()
    open var chooseDefitionView = UIView()
    private var chooseDefinitionHeightConstraint : NSLayoutConstraint!
    
    /// bottom view
    open var bottomWrapperView = UIView()
    open var currentTimeLabel = UILabel()
    open var totalTimeLabel   = UILabel()
    
    /// Progress slider
    open var timeSlider = BMTimeSlider()
    
    /// load progress view
    open var progressView = UIProgressView()
    
    /* play button
     playButton.isSelected = player.isPlaying
     */
    open var playButton = UIButton(type: UIButtonType.custom)
    
    /* fullScreen button
     fullScreenButton.isSelected = player.isFullscreen
     */
    open var fullscreenButton = UIButton(type: UIButtonType.custom)
    
    open var subtitleLabel    = UILabel()
    open var subtitleBackView = UIView()
    open var subtileAttribute: [NSAttributedStringKey : Any]?
    
    /// Activty Indector for loading
    open var loadingIndicator  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))
    
    open var seekToView       = UIView()
    open var seekToViewImage  = UIImageView()
    open var seekToLabel      = UILabel()
    
    open var replayButton     = UIButton(type: UIButtonType.custom)
    
    /// Gesture used to show / hide control view
    open var tapGesture: UITapGestureRecognizer!
    open var doubleTapGesture: UITapGestureRecognizer!
    
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
    open func loadedTimeDidChange(loadedDuration: TimeInterval, totalDuration: TimeInterval) {
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
        seekToView.isHidden = false
        seekToLabel.text    = BMPlayer.formatSecondsToString(toSecound)
        
        let rotate = isAdd ? 0 : CGFloat(Double.pi)
        seekToViewImage.transform = CGAffineTransform(rotationAngle: rotate)
        
        let targetTime = BMPlayer.formatSecondsToString(toSecound)
        timeSlider.value = Float(toSecound / totalDuration)
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
            if self?.playerLastState != .playedToTheEnd {
                self?.controlViewAnimation(isShow: false)
            }
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
     This function no longer handles status bar hiding/showing.
     - parameter isShow: is to show the controlview
     */
    open func controlViewAnimation(isShow: Bool) {
        let alpha: CGFloat = isShow ? 1.0 : 0.0
        self.isMaskShowing = isShow
        UIView.animate(withDuration: 0.3, animations: {
            self.topMaskView.alpha    = alpha
            self.bottomMaskView.alpha = alpha

            self.mainMaskView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: isShow ? 0.4 : 0.0)

            if isShow {
                if self.isFullscreen { self.chooseDefinitionView.alpha = 1.0 }
            } else {
                self.replayButton.isHidden = true

                if #available(iOS 9.0, *) {
                    self.chooseDefinitionHeightConstraint.isActive = false
                    self.chooseDefinitionHeightConstraint = self.chooseDefitionView.heightAnchor.constraint(equalToConstant: 35)
                    self.chooseDefinitionHeightConstraint.isActive = true
                } else {
                    fatalError(BMError.version.rawValue)

                }
                self.chooseDefinitionView.alpha = 0.0
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
        chooseDefinitionView.isHidden = !BMPlayerConf.enableChooseDefinition || !isForFullScreen
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
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    open func hideLoader() {
        loadingIndicator.isHidden = true
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
        for item in chooseDefinitionView.subviews {
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
            if #available(iOS 9.0, *) {
                button.addTarget(self, action: #selector(self.onDefinitionSelected(_:)), for: UIControlEvents.touchUpInside)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.topAnchor.constraint(equalTo: chooseDefitionView.topAnchor, constant: CGFloat(35 * i)).isActive = true
                button.widthAnchor.constraint(equalToConstant: 50).isActive = true
                button.heightAnchor.constraint(equalToConstant: 25).isActive = true
                button.centerXAnchor.constraint(equalTo: chooseDefitionView.centerXAnchor).isActive = true
            } else {
                fatalError(BMError.version.rawValue)
            }

            if resource.definitions.count == 1 {
                button.isEnabled = false
                button.isHidden = true
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
    
    @objc open func onDoubleTapGestureRecognized(_ gesture: UITapGestureRecognizer) {
        guard let player = player else { return }
        guard playerLastState == .readyToPlay || playerLastState == .buffering || playerLastState == .bufferFinished else { return }
        
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
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
                                                              attributes: subtileAttribute)
        } else {
            subtitleBackView.isHidden = true
        }
    }
    
    @available(iOS 9.0, *)
    @objc fileprivate func onDefinitionSelected(_ button:UIButton) {

        let height = isSelectecDefitionViewOpened ? 35 : resource!.definitions.count * 40
        chooseDefinitionHeightConstraint.isActive = false
        chooseDefinitionHeightConstraint = chooseDefitionView.heightAnchor.constraint(equalToConstant: CGFloat(height))
        chooseDefinitionHeightConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
        isSelectDefinitionViewOpened = !isSelectDefinitionViewOpened
        if selectedIndex != button.tag {
            selectedIndex = button.tag
            delegate?.controlView(controlView: self, didChooseDefinition: button.tag)
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
        if #available(iOS 9.0, *) {
            addConstraints()
        } else {
            fatalError(BMError.version.rawValue)
        }
        customizeUIComponents()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUIComponents()
        if #available(iOS 9.0, *) {
            addConstraints()
        } else {
            fatalError(BMError.version.rawValue)
        }
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
        mainMaskView.backgroundColor = UIColor(white: 0, alpha: 0.4 )
        
        // Top views
        topMaskView.addSubview(topWrapperView)
        topWrapperView.addSubview(backButton)
        topWrapperView.addSubview(titleLabel)
        topWrapperView.addSubview(chooseDefinitionView)
        
        backButton.tag = BMPlayerControlView.ButtonType.back.rawValue
        backButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_back"), for: .normal)
        backButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        titleLabel.textColor = UIColor.white
        titleLabel.text      = ""
        titleLabel.font      = UIFont.systemFont(ofSize: 16)
        
        chooseDefinitionView.clipsToBounds = true
        
        // Bottom views
        bottomMaskView.addSubview(bottomWrapperView)
        bottomWrapperView.addSubview(playButton)
        bottomWrapperView.addSubview(currentTimeLabel)
        bottomWrapperView.addSubview(totalTimeLabel)
        bottomWrapperView.addSubview(progressView)
        bottomWrapperView.addSubview(timeSlider)
        bottomWrapperView.addSubview(fullscreenButton)
        
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
        
        mainMaskView.addSubview(loadingIndicator)
        
        loadingIndicator.type  = BMPlayerConf.loaderType
        loadingIndicator.color = BMPlayerConf.tintColor
        
        // View to show when slide to seek
        addSubview(seekToView)
        seekToView.addSubview(seekToViewImage)
        seekToView.addSubview(seekToLabel)
        
        seekToLabel.font                = UIFont.systemFont(ofSize: 13)
        seekToLabel.textColor           = UIColor ( red: 0.9098, green: 0.9098, blue: 0.9098, alpha: 1.0 )
        seekToView.backgroundColor      = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7 )
        seekToView.layer.cornerRadius   = 4
        seekToView.layer.masksToBounds  = true
        seekToView.isHidden             = true
        
        seekToViewImage.image = BMImageResourcePath("Pod_Asset_BMPlayer_seek_to_image")
        
        addSubview(replayButton)
        replayButton.isHidden = true
        replayButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_replay"), for: .normal)
        replayButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        replayButton.tag = ButtonType.replay.rawValue
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGestureTapped(_:)))
        addGestureRecognizer(tapGesture)
        
        if BMPlayerManager.shared.enablePlayControlGestures {
            doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapGestureRecognized(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTapGesture)
            
            tapGesture.require(toFail: doubleTapGesture)
        }
    }
    
    @available(iOS 9.0, *)
    func addConstraints() {
        // Main mask view

        mainMaskView.translatesAutoresizingMaskIntoConstraints = false
        mainMaskView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainMaskView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mainMaskView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mainMaskView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        maskImageView.translatesAutoresizingMaskIntoConstraints = false
        mainMaskView.topAnchor.constraint(equalTo: mainMaskView.topAnchor).isActive = true
        mainMaskView.bottomAnchor.constraint(equalTo: mainMaskView.bottomAnchor).isActive = true
        mainMaskView.leadingAnchor.constraint(equalTo: mainMaskView.leadingAnchor).isActive = true
        mainMaskView.trailingAnchor.constraint(equalTo: mainMaskView.trailingAnchor).isActive = true

        topMaskView.translatesAutoresizingMaskIntoConstraints = false
        topMaskView.topAnchor.constraint(equalTo: mainMaskView.topAnchor).isActive = true
        topMaskView.leadingAnchor.constraint(equalTo: mainMaskView.leadingAnchor).isActive = true
        topMaskView.trailingAnchor.constraint(equalTo: mainMaskView.trailingAnchor).isActive = true
        topMaskView.heightAnchor.constraint(equalToConstant: 65).isActive = true

        bottomMaskView.translatesAutoresizingMaskIntoConstraints = false
        bottomMaskView.bottomAnchor.constraint(equalTo: mainMaskView.bottomAnchor).isActive = true
        bottomMaskView.leadingAnchor.constraint(equalTo: mainMaskView.leadingAnchor).isActive = true
        bottomMaskView.trailingAnchor.constraint(equalTo: mainMaskView.trailingAnchor).isActive = true
        bottomMaskView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Top views
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leadingAnchor.constraint(equalTo: topMaskView.leadingAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: topMaskView.bottomAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor).isActive = true

        chooseDefitionView.translatesAutoresizingMaskIntoConstraints = false
        chooseDefitionView.trailingAnchor.constraint(equalTo: topMaskView.trailingAnchor, constant: -20).isActive = true
        chooseDefitionView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4).isActive = true
        chooseDefitionView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        chooseDefinitionHeightConstraint = chooseDefitionView.heightAnchor.constraint(equalToConstant: 30)
        chooseDefinitionHeightConstraint.isActive = true

        // Bottom views
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.leadingAnchor.constraint(equalTo: bottomMaskView.leadingAnchor).isActive = true
        playButton.bottomAnchor.constraint(equalTo: bottomMaskView.bottomAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor).isActive = true
        currentTimeLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true

        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        let tempLeadingConstraint = timeSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 10)
        tempLeadingConstraint.priority = UILayoutPriority(750)
        tempLeadingConstraint.isActive = true
        timeSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor).isActive = true
        timeSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leadingAnchor.constraint(equalTo: timeSlider.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: timeSlider.trailingAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 2).isActive = true

        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.leadingAnchor.constraint(equalTo: timeSlider.trailingAnchor, constant: 5).isActive = true
        totalTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor).isActive = true
        totalTimeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true

        fullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        fullscreenButton.leadingAnchor.constraint(equalTo: totalTimeLabel.trailingAnchor).isActive = true
        fullscreenButton.trailingAnchor.constraint(equalTo: bottomMaskView.trailingAnchor).isActive = true
        fullscreenButton.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor).isActive = true
        fullscreenButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        fullscreenButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        loadingIndector.translatesAutoresizingMaskIntoConstraints = false
        loadingIndector.centerXAnchor.constraint(equalTo: mainMaskView.centerXAnchor).isActive = true
        loadingIndector.centerYAnchor.constraint(equalTo: mainMaskView.centerYAnchor).isActive = true

        // View to show when slide to seek
        seekToView.translatesAutoresizingMaskIntoConstraints = false
        seekToView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        seekToView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        seekToView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        seekToView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        seekToViewImage.translatesAutoresizingMaskIntoConstraints = false
        seekToViewImage.leadingAnchor.constraint(equalTo: seekToView.leadingAnchor, constant: 15).isActive = true
        seekToViewImage.centerYAnchor.constraint(equalTo: seekToView.centerYAnchor).isActive = true
        seekToViewImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
        seekToViewImage.heightAnchor.constraint(equalToConstant: 15).isActive = true

        seekToLabel.translatesAutoresizingMaskIntoConstraints = false
        seekToLabel.leadingAnchor.constraint(equalTo: seekToViewImage.trailingAnchor, constant: 10).isActive = true
        seekToLabel.centerYAnchor.constraint(equalTo: seekToView.centerYAnchor).isActive = true

        replayButton.translatesAutoresizingMaskIntoConstraints = false
        replayButton.leadingAnchor.constraint(equalTo: seekToViewImage.trailingAnchor, constant: 10).isActive = true
        replayButton.centerXAnchor.constraint(equalTo: mainMaskView.centerXAnchor).isActive = true
        replayButton.centerYAnchor.constraint(equalTo: mainMaskView.centerYAnchor).isActive = true
        replayButton.heightAnchor.constraint(equalToConstant:50).isActive = true

        subtitleBackView.translatesAutoresizingMaskIntoConstraints = false
        subtitleBackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        subtitleBackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        let tempWidthConstraint = subtitleBackView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 1, constant: -10)
        tempWidthConstraint.priority = UILayoutPriority(750)
        tempWidthConstraint.isActive = true

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: subtitleBackView.leadingAnchor, constant: 10).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: subtitleBackView.trailingAnchor, constant: -10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: subtitleBackView.topAnchor, constant: 2).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: subtitleBackView.bottomAnchor, constant: -2).isActive = true

    }
    
    fileprivate func BMImageResourcePath(_ fileName: String) -> UIImage? {
        let bundle = Bundle(for: BMPlayer.self)
        return UIImage(named: fileName, in: bundle, compatibleWith: nil)
    }
}

