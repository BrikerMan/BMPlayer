//
//  BMPlayerManager.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import UIKit
import NVActivityIndicatorView

let BMPlayerConf = BMPlayerManager.shared

class BMPlayerManager {
    /// 单例
    static let shared = BMPlayerManager()
    
    /// 主题色
    var tintColor   = UIColor.whiteColor()
    
    /// Loader样式
    var loaderType  = NVActivityIndicatorType.BallRotateChase

    /// 是否自动播放
    var shouldAutoPlay = true
    
    
    /// 是否打印log
    var allowLog  = true
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