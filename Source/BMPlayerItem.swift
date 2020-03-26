//
//  BMPlayerItem.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import Foundation
import AVFoundation

public class BMPlayerResource {
    public let name: String
    public let cover: URL?
    public var subtitle: BMSubtitles?
    public let definitions: [BMPlayerResourceDefinition]
    
    
    /**
     Player recource item with url, used to play single difinition video
     
     - parameter name:      video name
     - parameter url:       video url
     - parameter cover:     video cover, will show before playing, and hide when play
     - parameter subtitles: video subtitles
     */
    public convenience init(url: URL, name: String = "", cover: URL? = nil, subtitle: URL? = nil) {
        let definition = BMPlayerResourceDefinition(url: url, definition: "")
        
        var subtitles: BMSubtitles? = nil
        if let subtitle = subtitle {
            subtitles = BMSubtitles(url: subtitle)
        }
        
        self.init(name: name, definitions: [definition], cover: cover, subtitles: subtitles)
    }
    
    /**
     Play resouce with multi definitions
     
     - parameter name:        video name
     - parameter definitions: video definitions
     - parameter cover:       video cover
     - parameter subtitles:   video subtitles
     */
    public init(name: String = "", definitions: [BMPlayerResourceDefinition], cover: URL? = nil, subtitles: BMSubtitles? = nil) {
        self.name        = name
        self.cover       = cover
        self.subtitle    = subtitles
        self.definitions = definitions
    }
}


open class BMPlayerResourceDefinition {
    public let url: URL
    public let definition: String
    
    /// An instance of NSDictionary that contains keys for specifying options for the initialization of the AVURLAsset. See AVURLAssetPreferPreciseDurationAndTimingKey and AVURLAssetReferenceRestrictionsKey above.
    public var options: [String : Any]?
    
    open var avURLAsset: AVURLAsset {
        get {
            guard !url.isFileURL, url.pathExtension != "m3u8" else {
                return AVURLAsset(url: url)
            }
            return BMPlayerManager.asset(for: self)
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
