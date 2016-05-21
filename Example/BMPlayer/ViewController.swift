//
//  ViewController.swift
//  BMPlayer
//
//  Created by Eliyar Eziz on 04/28/2016.
//  Copyright (c) 2016 Eliyar Eziz. All rights reserved.
//

import UIKit
import BMPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let dataList = [
        "http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
        "http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
        "http://baobab.wdjcdn.com/14525705791193.mp4",
        "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
        "http://baobab.wdjcdn.com/1455968234865481297704.mp4",
        "http://baobab.wdjcdn.com/1455782903700jy.mp4",
        "http://baobab.wdjcdn.com/14564977406580.mp4",
        "http://baobab.wdjcdn.com/1456316686552The.mp4",
        "http://baobab.wdjcdn.com/1456480115661mtl.mp4",
        "http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
        "http://baobab.wdjcdn.com/1455614108256t(2).mp4",
        "http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
        "http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
        "http://baobab.wdjcdn.com/1456734464766B(13).mp4",
        "http://baobab.wdjcdn.com/1456653443902B.mp4",
        "http://baobab.wdjcdn.com/1456231710844S(24).mp4"]
    
    var videoItems = [BMPlayerItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<dataList.count {
            let item = BMPlayerItem(url: NSURL(string:dataList[i] )!, qualityName: "标准")
            videoItems.append(item)
        }
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let sender = sender as? Int ,
        vc = segue.destinationViewController as? VideoPlayViewController {
            vc.title = "网络视频 \(sender)"
            vc.item   = videoItems[sender]
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = "网络视频 \(indexPath.row)"
        cell.accessoryType   = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("pushVideoDetail", sender: indexPath.row)
    }
}