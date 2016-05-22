//
//  BMPlayerItem.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import Foundation

public class BMPlayerItem {
    var title   : String
    var resource : [BMPlayerItemDefinitionProtocol]
    var cover   : String
    
    public init(title: String, resource : [BMPlayerItemDefinitionProtocol], cover :String = "") {
        self.title    = title
        self.resource = resource
        self.cover    = cover
    }
}


public class BMPlayerItemDefinitionItem: BMPlayerItemDefinitionProtocol {
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