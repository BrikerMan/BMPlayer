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
    
    var index: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerManager()
        preparePlayer()
        setupPlayerResource()
    }
    
    /**
     prepare playerView
     */
    func preparePlayer() {
        player = BMPlayer()
        view.addSubview(player)
        player.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
        }
        player.delegate = self
        player.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen == true {
                return
            }
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
        /// Listening to player state changes with Block
        //Listen to when the player is playing or stopped
        player.playStateDidChange = { (isPlaying: Bool) in
            print("| BMPlayer Block | playStateDidChange \(isPlaying)")
        }
        
        //Listen to when the play time changes
        player.playTimeDidChange = { (currentTime: TimeInterval, totalTime: TimeInterval) in
            print("| BMPlayer Block | playTimeDidChange currentTime: \(currentTime) totalTime: \(totalTime)")
        }
        
        // player.panGesture.isEnabled = false
        self.view.layoutIfNeeded()
    }
    
    
    // 设置播放资源
    func setupPlayerResource() {
        switch (index.section,index.row) {
        // 普通播放器
        case (0,0):
            //            player.seek(22)
            player.videoGravity = "AVLayerVideoGravityResize"
            
            player.playWithURL(URL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")!, title: "风格互换：原来你我相爱")
            
        case (0,1):
            let item = self.preparePlayerItem()
            player.playWithPlayerItem(item)
            
        case (0,2):
            let item = self.preparePlayerItem()
            player.playWithPlayerItem(item)
            
        case (2,0):
            player.panGesture.isEnabled = false
            
        case (2,1):
            player.videoGravity = "AVLayerVideoGravityResizeAspect"
            player.playWithURL(URL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")!, title: "风格互换：原来你我相爱")
            
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
            BMPlayerConf.topBarShowInCase = .always
            
            
        case (1,1):
            BMPlayerConf.topBarShowInCase = .horizantalOnly
            
            
        case (1,2):
            BMPlayerConf.topBarShowInCase = .none
            
        case (1,3):
            BMPlayerConf.tintColor = UIColor.red
            
        default:
            break
        }
    }
    
    
    /**
     准备播放器资源model
     */
    func preparePlayerItem() -> BMPlayerItem {
        let resource0 = BMPlayerItemDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!,
                                                   definitionName: "高清")
        let resource1 = BMPlayerItemDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457529788412_5918_854x480.mp4")!,
                                                   definitionName: "标清")
        
        let item    = BMPlayerItem(title: "周末号外丨中国第一高楼",
                                   resource: [resource0, resource1],
                                   cover: "http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg")
        return item
    }
    
    
    func resetPlayerManager() {
        BMPlayerConf.allowLog = false
        BMPlayerConf.shouldAutoPlay = true
        BMPlayerConf.tintColor = UIColor.white
        BMPlayerConf.topBarShowInCase = .always
        BMPlayerConf.loaderType  = NVActivityIndicatorType.ballRotateChase
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        // If use the slide to back, remember to call this method
        // 使用手势返回的时候，调用下面方法
        player.pause(allowAutoPlay: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        // If use the slide to back, remember to call this method
        // 使用手势返回的时候，调用下面方法
        player.autoPlay()
    }
    
    deinit {
        // If use the slide to back, remember to call this method
        // 使用手势返回的时候，调用下面方法手动销毁
        player.prepareToDealloc()
        print("VideoPlayViewController Deinit")
    }
    
}

// MARK:- BMPlayerDelegate example
extension VideoPlayViewController: BMPlayerDelegate {
    // Call back when playing state changed, use to detect is playing or not
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        print("| BMPlayerDelegate | playerIsPlaying | playing - \(playing)")
    }
    
    // Call back when playing state changed, use to detect specefic state like buffering, bufferfinished
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
    }
    
    // Call back when play time change
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        print("| BMPlayerDelegate | playTimeDidChange | \(currentTime) of \(totalTime)")
    }
    
    // Call back when the video loaded duration changed
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        print("| BMPlayerDelegate | loadedTimeDidChange | \(loadedDuration) of \(totalDuration)")
    }
}
