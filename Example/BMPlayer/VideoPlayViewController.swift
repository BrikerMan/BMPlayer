//
//  VideoPlayViewController.swift
//  BMPlayer
//
//  Created by BrikerMan on 16/4/28.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import BMPlayer
import NVActivityIndicatorView

class VideoPlayViewController: UIViewController {
    
    //    @IBOutlet weak var player: BMPlayer!
    
    var player: BMPlayer!
    
    var index: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerManager()
        preparePlayer()
        setupPlayerResource()
    }
    
    /**
     准备playerView
     */
    func preparePlayer() {
//        let customView = CustomControlView()
        player = BMPlayer()
        view.addSubview(player)
        player.snp_makeConstraints { (make) in
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.height.equalTo(view.snp_width).multipliedBy(9.0/16.0)
        }
        
        player.backBlock = { [unowned self] in
            self.navigationController?.popViewControllerAnimated(true)
        }
        self.view.layoutIfNeeded()
    }
    
    
    // 设置播放资源
    func setupPlayerResource() {
        switch (index.section,index.row) {
        // 普通播放器
        case (0,0):
            player.playWithURL(NSURL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")!, title: "风格互换：原来你我相爱")
        case (0,1):
            let item = self.preparePlayerItem()
            player.playWithPlayerItem(item)
        case (0,2):
            let item = self.preparePlayerItem()
            player.playWithPlayerItem(item)
        default:
            let item = self.preparePlayerItem()
            player.playWithPlayerItem(item)
        }
    }
    
    // 设置播放器单例，修改属性
    func setupPlayerManager() {
        resetPlayerManager()
        switch (index.section,index.row) {
        // 普通播放器
        case (0,0):
            break
        case (0,1):
            break
        case (0,2):
            // 设置播放器属性，此情况下若提供了cover则先展示封面图，否则黑屏。点击播放后开始loading
            BMPlayerConf.shouldAutoPlay = false
            
        case (1,0):
            // 设置播放器属性，此情况下若提供了cover则先展示封面图，否则黑屏。点击播放后开始loading
            BMPlayerConf.topBarShowInCase = .Always
            
            
        case (1,1):
            BMPlayerConf.topBarShowInCase = .HorizantalOnly
    
            
        case (1,2):
            BMPlayerConf.topBarShowInCase = .None
            
        case (1,3):
            BMPlayerConf.tintColor = UIColor.redColor()
            
        default:
            break
        }
    }
    
    
    /**
     准备播放器资源model
     
     */
    func preparePlayerItem() -> BMPlayerItem {
        let resource0 = BMPlayerItemDefinitionItem(url: NSURL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!,
                                                   definitionName: "高清")
        let resource1 = BMPlayerItemDefinitionItem(url: NSURL(string: "http://baobab.wdjcdn.com/1457529788412_5918_854x480.mp4")!,
                                                   definitionName: "标清")
        
        let item    = BMPlayerItem(title: "周末号外丨中国第一高楼",
                                   resource: [resource0, resource1],
                                   cover: "http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg")
        return item
    }
    
    
    func resetPlayerManager() {
        BMPlayerConf.allowLog = false
        BMPlayerConf.shouldAutoPlay = true
        BMPlayerConf.tintColor = UIColor.whiteColor()
        BMPlayerConf.topBarShowInCase = .Always
        BMPlayerConf.loaderType  = NVActivityIndicatorType.BallRotateChase
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        // 使用手势返回的时候，调用下面方法
        player.pause(allowAutoPlay: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        // 使用手势返回的时候，调用下面方法
        player.autoPlay()
    }
    
    deinit {
        // 使用手势返回的时候，调用下面方法手动销毁
        player.prepareToDealloc()
        print("VideoPlayViewController Deinit")
    }
    
}
