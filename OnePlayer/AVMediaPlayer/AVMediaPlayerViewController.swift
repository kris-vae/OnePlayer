//
//  AVMediaPlayerViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/17.
//

import Foundation
import UIKit
import MobileVLCKit

class AVMediaPlayerViewController: UIViewController, VLCMediaPlayerDelegate{
    @IBOutlet weak var videoView: UIView!
    
    var mediaURL: URL? = URL.init(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
//    var mediaURL: URL? = URL.init(string: "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4")
    var mediaPlayer: VLCMediaPlayer!
    var media: VLCMedia!
    
//    init(url: URL) {
//        mediaURL = url
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        setupMediaPlayer()
        
        mediaPlayer.play()
    }
    
    func setupMediaPlayer() {
        let options = ["--codec=avcodec", "--network-caching=300"]
        media = VLCMedia.init(url: mediaURL!)
        mediaPlayer = VLCMediaPlayer.init(options: options)
        mediaPlayer.media = media
        mediaPlayer.delegate = self
        mediaPlayer.drawable = view
    }
}
