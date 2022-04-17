//
//  AVLocaleTableViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/4.
//

import Foundation
import UIKit

class AVLocaleTableViewController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView.init(frame: view.frame, style: .insetGrouped)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.textLabel?.text = "xiexie"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showAlbum", sender: self)
    }
}
