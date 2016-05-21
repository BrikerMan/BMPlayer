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
    
    var item: BMPlayerItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navView = UIView()
        navView.backgroundColor = UIColor.blackColor()
        view.addSubview(navView)
        
        navView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(view)
            make.height.equalTo(20)
        }
        
        
        player = BMPlayer()
        view.addSubview(player)
        player.snp_makeConstraints { (make) in
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.height.equalTo(view.snp_width).multipliedBy(9.0/16.0)
        }
        
        player.playWithQualityItems([item], title: self.title!)
        
        player.backBlock = { [unowned self] in
            self.navigationController?.popViewControllerAnimated(true)
        }
        self.view.layoutIfNeeded()
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
