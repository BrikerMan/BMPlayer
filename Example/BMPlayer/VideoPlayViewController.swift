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
    
    @IBOutlet weak var player: BMPlayer!
    
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
