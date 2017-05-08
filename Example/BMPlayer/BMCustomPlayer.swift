//
//  BMCustomPlayer.swift
//  BMPlayer
//
//  Created by Aqua on 2017/5/6.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import BMPlayer

class BMCustomPlayer: BMPlayer {
    class override func storyBoardCustomControl() -> BMPlayerControlView? {
        return BMPlayerCustomControlView()
    }
}
