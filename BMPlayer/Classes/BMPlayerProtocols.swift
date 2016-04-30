//
//  BMPlayerProtocols.swift
//  Pods
//
//  Created by BrikerMan on 16/4/30.
//
//

import UIKit

public protocol BMPlayerControllViewProtocol: class {
    var view: UIView  { get }
    
    var maskImageView    : UIImageView      { get set }
    var currentTimeLabel : UILabel          { get set }
    var totalTimeLabel   : UILabel          { get set }
    
    var playButton       : UIButton         { get set }
    var timeSlider       : UISlider         { get set }
    var progressView     : UIProgressView   { get set }
    var fullScreenButton : UIButton         { get set }
    var backButton       : UIButton         { get set }
    
    var loadIndector     : UIActivityIndicatorView { get set }
    var centerLabel      : UILabel          { get set }
    
    func showPlayerIcons()
    func hidePlayerIcons()
}