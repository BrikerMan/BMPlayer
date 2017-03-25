//
//  BMPlayerItem.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import Foundation
import AVFoundation

public struct BMPlayerResource {
    public let name: String
    public let definitions: [BMPlayerResourceDefinition]
    public let cover: URL?
    
    /**
     Player recource item with url, used to play single difinition video
     
     - parameter name:  video name
     - parameter url:   video url
     - parameter cover: video cover, will show before playing, and hide when play
     
     */
    public init( url: URL, name: String = "", cover: URL? = nil) {
        self.name = name
        self.cover = cover
        
        let definition = BMPlayerResourceDefinition(url: url, definition: "")
        self.definitions = [definition]
    }
    
    /**
     Play resouce with multi definitions
     
     - parameter name:        video name
     - parameter definitions: video definitions
     - parameter cover:       video cover
     */
    public init(name: String = "", definitions: [BMPlayerResourceDefinition], cover: URL? = nil) {
        self.name = name
        self.definitions = definitions
        self.cover = cover
    }
}


public struct BMPlayerResourceDefinition {
    public let url: URL
    public let definition: String
    
    /// An instance of NSDictionary that contains keys for specifying options for the initialization of the AVURLAsset. See AVURLAssetPreferPreciseDurationAndTimingKey and AVURLAssetReferenceRestrictionsKey above.
    public var options: [String : Any]?
    
    var avURLAsset: AVURLAsset {
        get {
            return AVURLAsset(url: url, options: options)
        }
    }
    
    /**
     Video recource item with defination name and specifying options
     
     - parameter url:        video url
     - parameter definition: url deifination
     - parameter options:    specifying options for the initialization of the AVURLAsset
     
     you can add http-header or other options which mentions in https://developer.apple.com/reference/avfoundation/avurlasset/initialization_options
     
     to add http-header init options like this 
     ```
        let header = ["User-Agent":"BMPlayer"]
        let definiton.options = ["AVURLAssetHTTPHeaderFieldsKey":header]
     ```
     */
    public init(url: URL, definition: String, options: [String : Any]? = nil) {
        self.url        = url
        self.definition = definition
        self.options    = options
    }
}


@available(*, deprecated, message: "please use BMPlayerResource")
open class BMPlayerItem {
    var title   : String
    var resource : [BMPlayerItemDefinitionProtocol]
    var cover   : String
    
    public init(title: String, resource : [BMPlayerItemDefinitionProtocol], cover :String = "") {
        self.title    = title
        self.resource = resource
        self.cover    = cover
    }
}

@available(*, deprecated, message: "please use BMPlayerResourceDefinition")
open class BMPlayerItemDefinitionItem: BMPlayerItemDefinitionProtocol {
    @objc open var playURL: URL
    @objc open var definitionName: String
    
    /**
     初始化播放资源
     
     - parameter url:         资源URL
     - parameter qualityName: 资源清晰度标签
     */
    public init(url:URL, definitionName: String) {
        self.playURL        = url
        self.definitionName = definitionName
    }
}


