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
    
    let cells = [
        [
            "普通播放器",
            "带清晰度切换",
            "不自动播放",
        ],[
            "顶部栏显示 - Always",
            "顶部栏显示 - HorizantalOnly",
            "顶部栏显示 - None",
            "TintColor - Red"
        ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let sender = sender as? NSIndexPath ,
            vc = segue.destinationViewController as? VideoPlayViewController {
            vc.index = sender
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = cells[indexPath.section][indexPath.row]
        cell.accessoryType   = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("pushVideoDetail", sender: indexPath)
    }
}