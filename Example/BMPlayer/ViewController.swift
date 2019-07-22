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
            "player - original",
            "player - definition switch",
            "player - disallow autoplay",
        ],[
            "topBarShow - Always",
            "topBarShow - HorizantalOnly",
            "topBarShow - None",
            "TintColor - Red"
        ],[
            "Custom Control UI",
            "Custom Control UI 2",
            "Custom Control UI In Storyboard"
        ]
    
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let sender = sender as? IndexPath ,
            let vc = segue.destination as? VideoPlayViewController {
            vc.index = sender
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cells[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.accessoryType   = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section, indexPath.row) == (2, 2) {
            performSegue(withIdentifier: "pushStoryboardPlayer", sender: indexPath)
        } else {
            performSegue(withIdentifier: "pushVideoDetail", sender: indexPath)
        }
    }
}
