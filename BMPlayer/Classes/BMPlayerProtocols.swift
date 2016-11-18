//
//  BMPlayerProtocols.swift
//  Pods
//
//  Created by BrikerMan on 16/4/30.
//
//

import UIKit

@objc public protocol BMPlayerItemDefinitionProtocol {
    /// 视频URL
    var playURL     : URL { get set }
    
    /// 清晰度名称，UI上展示，如高清，超清
    var definitionName : String { get set }
}

public protocol BMPlayerControlViewDelegate: class {
    /**
     call this mehod when user choose to change definetion
     
     - parameter index: definition item index
     */
    func controlViewDidChooseDefition(_ index: Int)
    
    /**
     call this method when user press on replay
     */
    func controlViewDidPressOnReply()
}


public protocol BMPlayerCustomControlView  {
    
    weak var delegate: BMPlayerControlViewDelegate? { get set }
    
    /// UI Items, More Detail on
    
    var playerTitleLabel        : UILabel?  { get }
    var playerCurrentTimeLabel  : UILabel?  { get }
    var playerTotalTimeLabel    : UILabel?  { get }
    
    var playerPlayButton        : UIButton? { get }
    var playerFullScreenButton  : UIButton? { get }
    var playerBackButton        : UIButton? { get }
    var playerReplayButton      : UIButton? { get }
    var playerRatioButton       : UIButton? { get }
    
    var playerTimeSlider        : UISlider? { get }
    var playerProgressView      : UIProgressView? { get }
    
    var playerSlowButton        : UIButton? { get }
    var playerMirrorButton      : UIButton? { get }
    
    var getView : UIView { get }
    
    /**
     call to prepare UI with definition items
     */
    func prepareChooseDefinitionView(_ items:[BMPlayerItemDefinitionProtocol], index: Int)
    
    
    /**
     call when UI needs to update, usually when screen orient did change
     
     - parameter isForFullScreen: is fullscreen
     */
    func updateUI(_ isForFullScreen: Bool)
    
    /**
     call when buffering
     */
    func showLoader()
    
    /**
     call when buffer finished
     */
    func hideLoader()
    
    /**
     call when user tapped on player to show player Ui components
     */
    func showPlayerUIComponents()
    
    /**
     call when user tapped on player to hide player Ui components
     */
    func hidePlayerUIComponents()
    
    /**
     call when video play did end
     */
    func showPlayToTheEndView()
    
    /**
     call when user slide to seek
     
     - parameter to:    target time
     - parameter isAdd: is slide to right
     */
    func showSeekToView(_ to:TimeInterval, isAdd: Bool)
    /**
     call when seek info view should hide
     */
    func hideSeekToView()
    
    /**
     call when needs to show cover image
     
     - parameter cover: cover url
     */
    func showCoverWithLink(_ cover:String)
    
    /**
     call when needs to hide cover image
     */
    func hideCoverImageView()
    
    func aspectRatioChanged(_ state:BMPlayerAspectRatio)
}

