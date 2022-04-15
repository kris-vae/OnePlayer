//
//  AVMedioPlayerViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/15.
//

import Foundation

class AVMediaPlayerViewController: UIViewController, VLCMediaPlayerDelegate {
    var mediaPlayer = VLCMediaPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaPlayer.delegate = self
        let url = URL.init(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        mediaPlayer.media = VLCMedia(url: url!)
        mediaPlayer.drawable = view
        mediaPlayer.play()
    }
}
