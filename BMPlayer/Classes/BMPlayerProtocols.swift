//
//  BMPlayerProtocols.swift
//  Pods
//
//  Created by BrikerMan on 16/4/30.
//
//

import UIKit

public protocol BMPlayerItemProtocol {
    /// 视频URL
    var playURL     : NSURL { get set }
    
    /// 清晰度名称，UI上展示，如高清，超清
    var qualityName : String { get set }
}