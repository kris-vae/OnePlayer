//
//  AVMediaPlayerViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/17.
//

import Foundation
import UIKit
import MobileVLCKit

class AVMediaPlayerViewController: UIViewController, VLCMediaPlayerDelegate, VLCMediaListPlayerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var mediaPlayerControllerView: UIView!
    
    @IBOutlet weak var videoViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mediaPlayerSlider: UISlider!
    @IBOutlet weak var mediaPlayerTime: UILabel!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnFullScreen: UIButton!
    
    @IBOutlet weak var btnFastForwardRate: UIButton!
    let rate: [Float] = [1, 1.5, 2]
    let rateDescription: [String] = ["1X", "1.5X", "2X"]
    var index : Int = 0 {
        didSet {
            btnFastForwardRate.setAttributedTitle(NSAttributedString.init(string: rateDescription[index], attributes: [.font: UIFont.init(name: "Helvetica", size: 12)!]), for: .normal)
            mediaPlayer.fastForward(atRate: rate[index])
        }
    }
    
    @IBOutlet weak var bufferingIndicator: UIActivityIndicatorView!
    
    var mediaURL: URL!
    var mediaPlayer: VLCMediaPlayer!
    var media: VLCMedia!
    
    var noTouchTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObserver()
        addGestureRecognizer()
        addTimer()
        
        setupUI()
        setupMediaPlayer()
        startMediaPlay()
    }
    
    func setupUI() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        hiddenBufferingIndicator()
        
        mediaPlayerSlider.setThumbImage(UIImage.init(named: "media.player.slider.circle"), for: .normal)
        mediaPlayerSlider.minimumTrackTintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        mediaPlayerSlider.maximumTrackTintColor = #colorLiteral(red: 0.0227137277, green: 0.5683634176, blue: 0.6150920994, alpha: 1)
        mediaPlayerSlider.value = 0
        
        mediaPlayerTime.textColor = .white
        
        btnPlay.setImage(UIImage.init(named: "media.player.start"), for: .normal)
        btnFullScreen.setImage(UIImage.init(named: "media.player.full.screen"), for: .normal)
        
        btnFastForwardRate.setAttributedTitle(NSAttributedString.init(string: "1X", attributes: [.font: UIFont.init(name: "Helvetica", size: 12)!]), for: .normal)
    }
    
    func addGestureRecognizer() {
        videoView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showMediaPlayerControllerView)))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view == view {
                showMediaPlayerControllerView()
            }
        }
    }
    
    func addTimer() {
        timerInvalidate()
        noTouchTimer = Timer.scheduledTimer(timeInterval: 5,
                                                  target: self,
                                                selector: #selector(hiddenMediaPlayerControllerView),
                                                userInfo: nil, repeats: false)
    }
    
    @objc func showMediaPlayerControllerView() {
        navigationController?.navigationBar.isHidden = false
        mediaPlayerControllerView.isHidden = false
        addTimer()
    }
    
    @objc func hiddenMediaPlayerControllerView() {
        mediaPlayerControllerView.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange),
                                                         name: UIDevice.orientationDidChangeNotification,
                                                       object: nil)
    }
    
    @objc func onDeviceOrientationChange() {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            videoViewHeightConstraint.constant = 220
            break;
        case .landscapeRight, .landscapeLeft, .portraitUpsideDown:
            videoViewHeightConstraint.constant = view.frame.height
            break
        default:
            videoViewHeightConstraint.constant = 220
        }
    }
    
    func setupMediaPlayer() {
        let options = ["--codec=avcodec", "--network-caching=300"]
        media = VLCMedia.init(url: mediaURL)
        
        mediaPlayer = VLCMediaPlayer.init(options: options)
        mediaPlayer.media = media
        mediaPlayer.delegate = self
        mediaPlayer.drawable = videoView
        
        mediaPlayerTime.text = "\(mediaPlayer.time.stringValue!)/\(mediaPlayer.remainingTime.stringValue!)"
        
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        mediaPlayerTime.text = "\(mediaPlayer.time.stringValue!)/\(mediaPlayer.remainingTime.stringValue!)"
        mediaPlayerSlider.value = mediaPlayer.position
    }
    
    func startMediaPlay() {
        mediaPlayer.play()
        btnPlay.setImage(UIImage.init(named: "media.player.stop"), for: .normal)
    }
    
    func pauseMediaPlay() {
        mediaPlayer.pause()
        btnPlay.setImage(UIImage.init(named: "media.player.start"), for: .normal)
    }
    
    func hiddenBufferingIndicator() {
        bufferingIndicator.isHidden = true
        bufferingIndicator.stopAnimating()
    }
    
    func showBufferingIndicator() {
        bufferingIndicator.isHidden = false
        bufferingIndicator.startAnimating()
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        let status = mediaPlayer.state
        switch status {
        case .ended:
            if UIDevice.current.value(forKey: "orientation") as! Int == UIInterfaceOrientation.landscapeRight.rawValue {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            navigationController?.popViewController(animated: true)
            break
        case .buffering:
            hiddenBufferingIndicator()
            break
        case .playing:
            hiddenBufferingIndicator()
            btnPlay.setImage(UIImage.init(named: "media.player.stop"), for: .normal)
            break
        case .opening:
            break
        case .paused:
            hiddenBufferingIndicator()
            btnPlay.setImage(UIImage.init(named: "media.player.start"), for: .normal)
            break
        case .esAdded:
            break
        case.stopped:
           showBufferingIndicator()
        default:
            hiddenBufferingIndicator()
            break
        }
    }
    
    @IBAction func changePlayerScreenStatus() {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case.portrait:
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            btnFullScreen.setImage(UIImage.init(named: "media.player.cancel.full.screen"), for: .normal)
            break
        case.landscapeLeft:
            btnFullScreen.setImage(UIImage.init(named: "media.player.full.screen"), for: .normal)
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            break
        default:
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            btnFullScreen.setImage(UIImage.init(named: "media.player.full.screen"), for: .normal)
            break;
        }
    }
    
    @IBAction func changePlayStatus() {
        if mediaPlayer.state == .paused {
            startMediaPlay()
        }else if mediaPlayer.state == .playing || mediaPlayer.state == .buffering {
            pauseMediaPlay()
        }
        
        showMediaPlayerControllerView()
    }
    
    @IBAction func slider(sender: UISlider) {
       mediaPlayer.position = sender.value
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func timerInvalidate() {
        if let _ = noTouchTimer {
            noTouchTimer.invalidate()
            noTouchTimer = nil
        }
    }
    
    @IBAction func changeFastFowardRate() {
        timerInvalidate()
        index = (index + 1) % rate.count
        addTimer()
    }
}
