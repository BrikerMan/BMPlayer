//
//  VideoPlayViewController.swift
//  BMPlayer
//
//  Created by BrikerMan on 16/4/28.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import BMPlayer

class VideoPlayViewController: UIViewController {
    
    //    @IBOutlet weak var player: BMPlayer!
    
    var player: BMPlayer!
    
    var index: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preparePlayer()
        preparePlayerForState()
        
    }
    
    /**
     准备playerView
     */
    func preparePlayer() {
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
    
    func preparePlayerForState() {
        switch (index.section,index.row) {
        // 普通播放器
        case (0,0):
            player.playWithURL(NSURL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")!, title: "风格互换：原来你我相爱")
        case (0,1):
            let resource0 = BMPlayerItemDefinitionItem(url: NSURL(string: "http://baobab.wdjcdn.com/14570071502774.mp4")!,
                                                       definitionName: "高清")
            let resource1 = BMPlayerItemDefinitionItem(url: NSURL(string: "http://baobab.wdjcdn.com/1457007294968_5824_854x480.mp4")!,
                                                      definitionName: "标清")

            let item    = BMPlayerItem(title: "周末号外丨川普版权力的游戏",
                                       resorce: [resource0, resource1],
                                       cover: "http://img.wdjimg.com/image/video/acdba01e52efe8082d7c33556cf61549_0_0.jpeg")
            //
            player.playWithPlayerItem(item)
        default:
            break
        }
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
