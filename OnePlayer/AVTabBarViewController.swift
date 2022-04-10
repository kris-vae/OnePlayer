//
//  AVTabBarViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/4.
//

import Foundation
import UIKit

class AVTabBarController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBarItemImage()
        setupBarItemTitle()
    }
    
    func setupBarItemImage() {
        tabBar.items?[0].image = UIImage.init(named: "icon.local")?.withRenderingMode(.alwaysOriginal)
        tabBar.items?[0].selectedImage = UIImage.init(named: "icon.local.selected")?.withRenderingMode(.alwaysOriginal)
        
        tabBar.items?[1].image = UIImage.init(named: "icon.list")?.withRenderingMode(.alwaysOriginal)
        tabBar.items?[1].selectedImage = UIImage.init(named: "icon.list.selected")?.withRenderingMode(.alwaysOriginal)
        
        tabBar.items?[2].image = UIImage.init(named: "icon.download")?.withRenderingMode(.alwaysOriginal)
        tabBar.items?[2].selectedImage = UIImage.init(named: "icon.download.selected")?.withRenderingMode(.alwaysOriginal)
        
        tabBar.items?[3].image = UIImage.init(named: "icon.setting")?.withRenderingMode(.alwaysOriginal)
        tabBar.items?[3].selectedImage = UIImage.init(named: "icon.setting.selected")?.withRenderingMode(.alwaysOriginal)
    }
    
    func setupBarItemTitle() {
        tabBar.items?[0].title = "本地"
        tabBar.items?[1].title = "播放列表"
        tabBar.items?[2].title = "下载"
        tabBar.items?[3].title = "设置"
    }
}
