//
//  BMPlayerManager.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import UIKit
import VIMediaCache
import AVFoundation

import NVActivityIndicatorView

public let BMPlayerConf = BMPlayerManager.shared

public enum BMPlayerTopBarShowCase: Int {
    case always         = 0 /// 始终显示
    case horizantalOnly = 1 /// 只在横屏界面显示
    case none           = 2 /// 不显示
}

open class BMPlayerManager {
    /// 单例
    public static let shared = BMPlayerManager()
    
    /// tint color
    open var tintColor   = UIColor.white
    
    /// Loader
    open var loaderType  = NVActivityIndicatorType.ballRotateChase
    
    /// should auto play
    open var shouldAutoPlay = true
    
    open var topBarShowInCase = BMPlayerTopBarShowCase.always
    
    open var animateDelayTimeInterval = TimeInterval(5)
    
    /// should show log
    open var allowLog  = false
    
    /// use gestures to set brightness, volume and play position
    open var enableBrightnessGestures = true
    open var enableVolumeGestures = true
    open var enablePlaytimeGestures = true
    open var enableChooseDefinition = true
    open var enablePlayControlGestures = true

    open var cacheManeger = VIResourceLoaderManager()
    
    
    internal static func asset(for resouce: BMPlayerResourceDefinition) -> AVURLAsset {
        let asset = BMPlayerManager.shared.cacheManeger.playerItem(with: resouce.url)
        return asset!.asset as! AVURLAsset
    }
    
    /**
     打印log
     
     - parameter info: log信息
     */
    func log(_ info:String) {
        if allowLog {
            print(info)
        }
    }
}
