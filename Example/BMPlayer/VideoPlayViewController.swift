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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        player.play()
    }
    
    deinit {
        print("VideoPlayViewController Deinit")
    }
    
}
