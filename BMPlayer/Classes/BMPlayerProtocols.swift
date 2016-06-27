//
//  BMPlayerProtocols.swift
//  Pods
//
//  Created by BrikerMan on 16/4/30.
//
//

import UIKit

public protocol BMPlayerItemDefinitionProtocol {
    /// 视频URL
    var playURL     : NSURL { get set }
    
    /// 清晰度名称，UI上展示，如高清，超清
    var definitionName : String { get set }
}

public protocol BMPlayerControlViewDelegate: class {
    func controlViewDidChooseDefition(index: Int)
    func controlViewDidPressOnReply()
}


public protocol BMPlayerCustomControlView  {
    
    weak var delegate: BMPlayerControlViewDelegate? { get set }
    var playerTitleLabel        : UILabel?  { get }
    var playerCurrentTimeLabel  : UILabel?  { get }
    var playerTotalTimeLabel    : UILabel?  { get }
    
    var playerPlayButton        : UIButton? { get }
    var playerFullScreenButton  : UIButton? { get }
    var playerBackButton        : UIButton? { get }
    
    var playerTimeSlider        : UISlider? { get }
    var playerProgressView      : UIProgressView? { get }
    
    var playerSlowButton        : UIButton? { get }
    var playerMirrorButton      : UIButton? { get }
    
    var getView : UIView { get }
    
    
    func showLoader()
    func hideLoader()
    func showPlayerUIComponents()
    func hidePlayerUIComponents()
    func prepareChooseDefinitionView(items:[BMPlayerItemDefinitionProtocol], index: Int)
    
    func showPlayToTheEndView()
    
    func updateUI(isForFullScreen: Bool)
    
}

extension BMPlayerCustomControlView {
    func showSeekToView(to:NSTimeInterval, isAdd: Bool) { }
    func hideSeekToView()  { }
    func showCoverWithLink(cover:String)  { }
    func hideCoverImageView()  { }
}

