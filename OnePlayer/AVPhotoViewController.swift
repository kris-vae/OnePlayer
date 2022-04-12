//
//  AVPhotoSlideViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/6.
//

import Foundation
import UIKit
import Photos

class AVPhotoViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate{
    
    let scrollViewWidth = UIScreen.main.bounds.width
    let scrollViewHeight = UIScreen.main.bounds.height
    
    let cacheImageManager = PHCachingImageManager.init()
    var assets: PHFetchResult<PHAsset> {
        didSet {
            let options = PHImageRequestOptions.init()
            options.deliveryMode = .highQualityFormat
            cacheImageManager.startCachingImages(for: assetArr,
                                          targetSize: PHImageManagerMaximumSize,
                                         contentMode: .aspectFit,
                                             options: nil)
        }
        
        willSet {
            cacheImageManager.stopCachingImagesForAllAssets()
        }
    }
    
    var assetArr: [PHAsset] {
        get {
            var result: [PHAsset] = []
            assets.enumerateObjects { (object, _, _) in result.append(object)}
            return result
        }
    }
    
    var photos: Array<UIImage?>!
    
    var photosTitle: Array<String> {
        get {
            var result: Array<String> = []
            
            for asset in assetArr {
                result.append(asset.localIdentifier)
            }
            
            return result
        }
    }
    
    var photoTotalNumber: Int {
        get {
            return assets.count
        }
    }
    
    var currentPhotoIndex: Int! {
        didSet {
            navigationItem.title = String.init(format: "%@(%@/%@)", assetArr[currentPhotoIndex].originalFilename!, String(Int(currentPhotoIndex)+1), String(photoTotalNumber))
        }
    }
    
    var scrollPhotoContainView: AVScrollPhotoView!
    
    @IBOutlet var slideTimeChooseContainView: UIView!
    
    let slideSeconds: Array<Int> = [2, 5, 10, 15, 20, 25, 30, 45, 60]
    let leadingConstraint: CGFloat = 15
    let trailingConstraint: CGFloat = -15
    let containViewHeight: CGFloat = 460
    
    var slideTimer: Timer!
    var isSliding: Bool = false
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) not implemented")
    }

    init?(assets: PHFetchResult<PHAsset>, index: Int, coder: NSCoder) {
        self.assets = assets
        self.currentPhotoIndex = index
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollPhotoContainView = AVScrollPhotoView.init(photoNumber: photoTotalNumber)
        self.view.addSubview(scrollPhotoContainView)
        
        photos = Array.init(repeating: nil, count: photoTotalNumber)
        
        setupUI()
        addGestureRecognizer()
        addNotification()
    }
    
    func setupUI() {
        tabBarController?.tabBar.isHidden = true
        navigationItem.title = String.init(format: "%@(%@/%@)", assetArr[currentPhotoIndex].originalFilename!, String(Int(currentPhotoIndex)+1), String(photoTotalNumber))
        
        setupScrollContainView()
    }
    
    func setupScrollContainView() {
        if photoTotalNumber == 1 {
            setImageFor(imageView: scrollPhotoContainView.leftImgView, atAssetIndex: currentPhotoIndex)
        }else {
            setImageFor(imageView: scrollPhotoContainView.middleImgView, atAssetIndex: currentPhotoIndex)
        }
    }
    
    func addGestureRecognizer() {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(changeStatus))
        tapGestureRecognizer.delegate = self
        self.scrollPhotoContainView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(currentIndexIncrease), name: .leftSlide, object: scrollPhotoContainView)
        NotificationCenter.default.addObserver(self, selector: #selector(currentIndexDecrease), name: .rightSlide, object: scrollPhotoContainView)
        NotificationCenter.default.addObserver(self, selector: #selector(updateScrollContainView), name: .updatePhoto, object: scrollPhotoContainView)
    }
    
    @objc func currentIndexIncrease() {
        currentPhotoIndex = currentPhotoIndex + 1 == photoTotalNumber ? 0 : currentPhotoIndex + 1
    }
    
    @objc func currentIndexDecrease() {
        currentPhotoIndex = currentPhotoIndex - 1 < 0 ? photoTotalNumber-1 : currentPhotoIndex - 1
    }
    
    @objc func updateScrollContainView() {
        if currentPhotoIndex == 0 {
            setImageFor(imageView: scrollPhotoContainView.leftImgView, atAssetIndex: photoTotalNumber-1)
            setImageFor(imageView: scrollPhotoContainView.middleImgView, atAssetIndex: currentPhotoIndex)
            setImageFor(imageView: scrollPhotoContainView.rightImgView, atAssetIndex: currentPhotoIndex+1)
        }else if currentPhotoIndex == photoTotalNumber - 1 {
            setImageFor(imageView: scrollPhotoContainView.leftImgView, atAssetIndex: currentPhotoIndex-1)
            setImageFor(imageView: scrollPhotoContainView.middleImgView, atAssetIndex: currentPhotoIndex)
            setImageFor(imageView: scrollPhotoContainView.rightImgView, atAssetIndex: 0)
        }else {
            setImageFor(imageView: scrollPhotoContainView.leftImgView, atAssetIndex: currentPhotoIndex-1)
            setImageFor(imageView: scrollPhotoContainView.middleImgView, atAssetIndex: currentPhotoIndex)
            setImageFor(imageView: scrollPhotoContainView.rightImgView, atAssetIndex: currentPhotoIndex+1)
        }
    }
    
    func setImageFor(imageView: UIImageView, atAssetIndex index: Int) {
        if let image = photos[index] {
            imageView.image = image
            return
        }
        
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: assetArr[index], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: { (image, _) in
            imageView.image = image
            self.photos[index] = image
        })
        
    }
    
    @objc func changeStatus() {
        if isSliding {
            isSliding = false
            slideTimer.invalidate()
            slideTimer = nil
            navigationController?.navigationBar.isHidden = false
        }else {
            navigationController?.navigationBar.isHidden = !(navigationController?.navigationBar.isHidden)!
        }
    }
    
    @IBAction func dismissClicked() {
        navigationController?.popViewController(animated: true)
    }

    func setupSlideTimeChooseContainView() {
        slideTimeChooseContainView.translatesAutoresizingMaskIntoConstraints = false
        slideTimeChooseContainView.frame.origin = CGPoint.init(x: 0, y: scrollViewHeight)
        slideTimeChooseContainView.layer.cornerRadius = 10
        slideTimeChooseContainView.layer.borderWidth = 1
    }
    
    //判断手势范围，UITableView不响应添加到self.view的手势操作
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isKind(of: UITableViewCell.self) {
            return false
        }
        
        if let view = touch.view?.superview, view.isKind(of: UITableViewCell.self) {
            return false
        }
        
        if let view = touch.view?.superview?.superview, view.isKind(of: UITableViewCell.self) {
            return false
        }
        
        return true
    }
    
    @objc func leftSlide() {
        UIView.animate(withDuration: 1,
                         animations: {
            self.scrollPhotoContainView.scrollView.contentOffset.x = self.scrollViewWidth*2
        },
                       completion: { (isCompleted) in
            self.scrollPhotoContainView.scrollView.contentOffset.x = self.scrollViewWidth
            })
    }
    
    func slideStartWith(_ timeInterval: TimeInterval) {
        isSliding = true
        self.scrollPhotoContainView.scrollView.canCancelContentTouches = false
        self.scrollPhotoContainView.scrollView.delaysContentTouches = true
        navigationController?.navigationBar.isHidden = true
        slideTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(leftSlide), userInfo: nil, repeats: true)
    }
    
    func addAlertSheet(_ alertController: UIAlertController) {
        for index in 0..<slideSeconds.count {
            alertController.addAction(UIAlertAction.init(title: String.init(format: "%@s", String(slideSeconds[index])), style: .default, handler: { [self] (action) in
                slideStartWith(Double(slideSeconds[index]))
            }))
        }
        
        alertController.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
    }
    
    @IBAction func addslideTimeChooseAlert() {
        let slideTimeChooseAlert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        addAlertSheet(slideTimeChooseAlert)
        present(slideTimeChooseAlert, animated: true)
    }
}

extension PHAsset {
    var originalFilename: String? {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
}

extension Notification.Name{
    static let leftSlide = Notification.Name("leftSlide")
    static let rightSlide = Notification.Name("rightSlide")
    static let updatePhoto = Notification.Name("updatePhoto")
}

