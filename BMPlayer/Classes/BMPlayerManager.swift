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
    case always         = 0 /// 始终显示
    case horizantalOnly = 1 /// 只在横屏界面显示
    case none           = 2 /// 不显示
}

open class BMPlayerManager {
    /// 单例
    open static let shared = BMPlayerManager()
    
    /// 主题色
    open var tintColor   = UIColor.white
    
    /// Loader样式
    open var loaderType  = NVActivityIndicatorType.ballRotateChase
    
    /// 是否自动播放
    open var shouldAutoPlay = true
    
    open var topBarShowInCase = BMPlayerTopBarShowCase.always
    
    /// 是否显示慢放和镜像按钮
    open var slowAndMirror = false
    
    /// 是否显示比例切换按钮
    open var showScaleChangeButton = false
    
    /// 是否打印log
    open var allowLog  = false
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
