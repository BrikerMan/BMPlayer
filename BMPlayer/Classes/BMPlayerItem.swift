//
//  BMPlayerItem.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import Foundation

public class BMPlayerItem: BMPlayerItemProtocol {
    public var playURL: NSURL
    public var definitionName: String
    
    /**
     初始化播放资源
     
     - parameter url:         资源URL
     - parameter qualityName: 资源清晰度标签
     */
    public init(url:NSURL, definitionName: String) {
        self.playURL        = url
        self.definitionName = definitionName
    }
}