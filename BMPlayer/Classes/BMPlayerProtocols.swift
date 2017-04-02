//
//  BMPlayerProtocols.swift
//  Pods
//
//  Created by BrikerMan on 16/4/30.
//
//

import UIKit

@available(*, deprecated: 0.8.0)
@objc public protocol BMPlayerItemDefinitionProtocol {
    /// 视频URL
    var playURL     : URL { get set }
    
    /// 清晰度名称，UI上展示，如高清，超清
    var definitionName : String { get set }
}
