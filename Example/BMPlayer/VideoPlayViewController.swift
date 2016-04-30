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
    
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = BMPlayer()
        view.addSubview(player)
        player.snp_makeConstraints { (make) in
            make.top.equalTo(self.view).offset(20)
            make.left.right.equalTo(self.view)
            // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
            make.height.equalTo(player.snp_width).multipliedBy(9/16).priority(750)
        }
        
        player.playWithURL(NSURL(string: url)!)
        
        player.backBlock = { [unowned self] in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        player.pause()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        player.play()
    }
    
    
    
    deinit {
        print("VideoPlayViewController Deinit")
    }
    
}
