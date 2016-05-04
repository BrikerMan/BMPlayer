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
        "http://pl.youku.com/playlist/m3u8?ts=1462273286&keyframe=0&ykss=ff842857d381da96211ba4c3&pid=69b81504767483cf&vid=XMTU1MTc0NDgwNA==&type=flv&r=s0KfeG/MpJGxT8zBRdWN/LVC7tut611BSE41Kpa3TP458/QxZV04id1aeqGbo6gH8PUpNx0Ap7OdJBVOT/S01ZODSy6Mv/nJMSqqUC/vobF4VZ4d40lytN0O4MeYDHBrYDosUvY0B4jgOB68cL/amnd2uoaVgi5HSFKSDf24NnAS0HjEYPwPEowaQRAx34uUuW10ScZrNh95iNWKAqYEBjnVfXLqLyyVfm20RjvEPxceONtxuNQ7TChnku8jnsVijaLiauMYJvWl+xSzLDe6wi9DjO+KHJELFeA4sbzpVtKqInnv1Y6TJEMikJs12+fv&sid=046227328679121b9111e&token=6116&&oip=757078857&&ep=advMucTUQ8agbrAuByrrtTC6DAsRN6A3JsiCxhqobqgZ7iTU8sS1aJQVlEvSbrGG&did=65c906c26a8703f45f2f64b92bff8203e8697e75&ctype=21&ev=1",
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let sender = sender as? Int ,
        vc = segue.destinationViewController as? VideoPlayViewController {
            vc.title = "网络视频 \(sender)"
            vc.url   = dataList[sender]
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