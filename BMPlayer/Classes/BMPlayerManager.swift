//
//  BMPlayerManager.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import UIKit
import NVActivityIndicatorView

public let BMPlayerConf = BMPlayerManager.shared

public enum BMPlayerTopBarShowCase: Int {
    case Always         = 0 /// 始终显示
    case HorizantalOnly = 1 /// 只在横屏界面显示
    case None           = 2 /// 不显示
}

public class BMPlayerManager {
    /// 单例
    public static let shared = BMPlayerManager()
    
    /// 主题色
    public var tintColor   = UIColor.whiteColor()
    
    /// Loader样式
    public var loaderType  = NVActivityIndicatorType.BallRotateChase

    /// 是否自动播放
    public var shouldAutoPlay = true
    
    public var topBarShowInCase = BMPlayerTopBarShowCase.Always
    
    /// 是否显示慢放和镜像按钮
    public var slowAndMirror = false
    
    /// 是否打印log
    public var allowLog  = false
    /**
     打印log
     
     - parameter info: log信息
     */
    func log(info:String) {
        if allowLog {
            print(info)
        }
    }
}