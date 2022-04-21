//
//  AVMediaListViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/18.
//

import Foundation
import UIKit

class AVMediaListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var tableView: UITableView!
    
    var mediaList: [String] = ["https://stream7.iqilu.com/10339/upload_transcode/202002/09/20200209104902N3v5Vpxuvb.mp4",
         "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4",
         "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4",
         "http://1011.hlsplay.aodianyun.com/demo/game.flv",
         "https://sf1-hscdn-tos.pstatp.com/obj/media-fe/xgplayer_doc_video/flv/xgplayer-demo-360p.flv"
        ]
    
    var mediaName: [String] = ["我是疫情科普视频", "我是一个鸟视频", "我是甄子丹", "我是Miss直播", "我是垃圾视频"]
    var didSelectMediaURL: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init()
        cell.textLabel?.text = mediaName[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaList.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? AVMediaPlayerViewController else {
            return
        }
        
        viewController.mediaURL = URL.init(string: didSelectMediaURL)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectMediaURL = mediaList[indexPath.row]
        performSegue(withIdentifier: "playMedia", sender: nil)
    }
}
