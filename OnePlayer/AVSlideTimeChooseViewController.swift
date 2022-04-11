//
//  AVSlideTimeChooseView.swift
//  OnePlayer
//
//  Created by kris on 2022/4/11.
//

import Foundation
import UIKit

class AVSlideTimeChooseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCancel: UIButton!
    
    var didSelectedSlideTime: Int!
    
    let slideSeconds: Array<Int> = [2, 5, 10, 15, 20, 25, 30, 45, 60]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupUI()
    }
    
    func setupUI() {
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        btnCancel.layer.cornerRadius = 10
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slideSeconds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AVSlideTimeChooseTableViewCell.reuseIdentifier, for: indexPath) as? AVSlideTimeChooseTableViewCell else {
            return UITableViewCell.init()
        }
        
        cell.update(slideSeconds[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectedSlideTime = slideSeconds[indexPath.row]
        NotificationCenter.default.post(name: .slideTimeDidChoose, object: nil)
    }
    
    @IBAction func btnCancelClicked() {
        NotificationCenter.default.post(name: .chooseSlideTimeCancel, object: nil)
    }
}

extension Notification.Name{
    static let chooseSlideTimeCancel = Notification.Name("cancelSlideTimeChoose")
    static let slideTimeDidChoose = Notification.Name("slideTimeDidChoose")
}

