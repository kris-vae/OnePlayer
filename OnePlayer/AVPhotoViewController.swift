//
//  AVPhotoSlideViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/6.
//

import Foundation
import UIKit
import Photos

class AVPhotoViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{
    let cacheImageManager = PHCachingImageManager.init()
    
    var assetArr: [PHAsset] {
        get {
            var result: [PHAsset] = []
            assets.enumerateObjects { (object, _, _) in result.append(object)}
            return result
        }
    }
    
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
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) not implemented")
    }

    init?(assets: PHFetchResult<PHAsset>, index: Int, coder: NSCoder) {
        self.assets = assets
        self.currentPhotoIndex = index
        super.init(coder: coder)
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
    
    var scrollView: UIScrollView!
    var scrollViewWidth: CGFloat {
        get {
            return UIScreen.main.bounds.width
        }
    }
    var scrollViewHeight: CGFloat {
        get {
            UIScreen.main.bounds.height
        }
    }
    
    var leftImgView: UIImageView!
    var middleImgView: UIImageView!
    var rightImgView: UIImageView!
    
    var didInitializeView: Bool = false
    
    @IBOutlet var slideTimeChoiceConatinView: UIStackView!
    let containViewHeight: CGFloat = 460
    @IBOutlet weak var slideSecondTableView: UITableView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    
    var slideTimer: Timer!
    var isSliding: Bool = false
    
    let slideSecond: Array<Double> = [2, 5, 10, 15, 20, 25, 30, 45, 60]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photos = Array.init(repeating: nil, count: photoTotalNumber)
        initializeView()
        setupNavigationBarUI()
        addTouchEvent()
        tabBarController?.tabBar.isHidden = true
        slideTimeChoiceConatinView.removeFromSuperview()
    }
    
    func setupNavigationBarUI() {
        navigationItem.title = String.init(format: "%@(%@/%@)", assetArr[currentPhotoIndex].originalFilename!, String(Int(currentPhotoIndex)+1), String(photoTotalNumber))
    }
    
    func addTouchEvent() {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(changeStatus))
        tapGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func changeStatus() {
        if isSliding {
            isSliding = false
            slideTimer.invalidate()
            slideTimer = nil
            navigationController?.navigationBar.isHidden = false
        }else {
            guard let isHidden = navigationController?.navigationBar.isHidden else {
                return
            }
            if slideTimeChoiceConatinView.superview == view {
                dismissSlideContainView()
                navigationController?.navigationBar.isHidden = false
            }else {
                navigationController?.navigationBar.isHidden = !isHidden
            }
        }
    }
    
    func initializeImgView() -> UIImageView {
        let imgView: UIImageView = UIImageView.init()
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        
        let imgViewWidthConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: imgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: scrollViewWidth)
        let imgViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: imgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: scrollViewHeight)
        
        imgView.addConstraints([imgViewWidthConstraint, imgViewHeightConstraint])
        
        return imgView
    }
    
    func initializeScrollView() -> UIScrollView {
        let scrollView: UIScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
    
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        if photoTotalNumber == 1 {
            scrollView.contentSize = CGSize.init(width: scrollViewWidth+20, height: scrollViewHeight)
            scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        }else {
            scrollView.contentSize = CGSize.init(width: scrollViewWidth*3, height: scrollViewHeight)
            scrollView.contentOffset = CGPoint.init(x: scrollViewWidth, y: 0)
        }
        
        return scrollView
    }
    
    func addConstraints() {
        scrollView.addConstraint(NSLayoutConstraint.init(item: leftImgView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint.init(item: leftImgView, attribute: .centerY, relatedBy: .equal, toItem: self.scrollView, attribute: .centerY, multiplier: 1, constant: 0))
        
        if photoTotalNumber > 1 {
            scrollView.addConstraint(NSLayoutConstraint.init(item: middleImgView, attribute: .leading, relatedBy: .equal, toItem: leftImgView, attribute: .trailing, multiplier: 1, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint.init(item: middleImgView, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1, constant: 0))
            
            scrollView.addConstraint(NSLayoutConstraint.init(item: rightImgView, attribute: .leading, relatedBy: .equal, toItem: middleImgView, attribute: .trailing, multiplier: 1, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint.init(item: rightImgView, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1, constant: 0))
        }
    }
    
    func addSubViews() {
        scrollView.addSubview(leftImgView)
        
        if photoTotalNumber > 1 {
            scrollView.addSubview(middleImgView)
            scrollView.addSubview(rightImgView)
        }
        view.addSubview(scrollView)
    }
    
    func initializeView() {
        scrollView = initializeScrollView()
        leftImgView = initializeImgView()
        
        if photoTotalNumber == 1 {
            setImageFor(imageView: leftImgView, atAssetIndex: currentPhotoIndex)
        }else {
            middleImgView = initializeImgView()
            setImageFor(imageView: middleImgView, atAssetIndex: currentPhotoIndex)
            rightImgView = initializeImgView()
          
        }
       
        addSubViews()
        addConstraints()
        
        didInitializeView = true
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
    
    func updateImageView() {
        if currentPhotoIndex == 0 {
            setImageFor(imageView: leftImgView, atAssetIndex: photoTotalNumber-1)
            setImageFor(imageView: middleImgView, atAssetIndex: currentPhotoIndex)
            setImageFor(imageView: rightImgView, atAssetIndex: currentPhotoIndex+1)
        }else if currentPhotoIndex == photoTotalNumber - 1{
            setImageFor(imageView: leftImgView, atAssetIndex: currentPhotoIndex-1)
            setImageFor(imageView: middleImgView, atAssetIndex: currentPhotoIndex)
            setImageFor(imageView: rightImgView, atAssetIndex: 0)
        }else {
            setImageFor(imageView: leftImgView, atAssetIndex: currentPhotoIndex-1)
            setImageFor(imageView: middleImgView, atAssetIndex: currentPhotoIndex)
            setImageFor(imageView: rightImgView, atAssetIndex: currentPhotoIndex+1)
        }
    }
    
    func setupScrollView() {
        if didInitializeView && photoTotalNumber > 1 {
            let offset: CGFloat = scrollView.contentOffset.x
            
            if offset >= scrollViewWidth * 2 {
                scrollView.contentOffset = CGPoint.init(x: scrollViewWidth, y: 0)
                currentPhotoIndex = currentPhotoIndex + 1 == photoTotalNumber ? 0 : currentPhotoIndex + 1
            }else if offset <= 0 {
                scrollView.contentOffset = CGPoint.init(x: scrollViewWidth, y: 0)
                currentPhotoIndex = currentPhotoIndex - 1 < 0 ? photoTotalNumber-1 : currentPhotoIndex - 1
            }
            updateImageView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupScrollView()
    }
    
    @IBAction func dismissClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func slideClicked() {
        view.addSubview(slideTimeChoiceConatinView)
        slideTimeChoiceConatinView.translatesAutoresizingMaskIntoConstraints = false
        slideTimeChoiceConatinView.frame.origin = CGPoint.init(x: 0, y: scrollViewHeight)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.slideTimeChoiceConatinView.frame.origin = CGPoint.init(x: 0, y: self.scrollViewHeight-self.containViewHeight)
        })
        
        addConstraintsForContainView()
        setupContainView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slideSecond.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = slideSecondTableView.dequeueReusableCell(withIdentifier: "slideSecond") as? AVSlidePhotoTimeTableViewCell else {
            return UITableViewCell.init()
        }
        cell.selectionStyle = .none
        cell.lblSecond.text = String.init(format: "%@s", String(Int(slideSecond[indexPath.row])))
        
        return cell
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
            self.scrollView.contentOffset.x = self.scrollViewWidth*2
        },
                       completion: { (isCompleted) in
            self.scrollView.contentOffset.x = self.scrollViewWidth
            })
    }
    
    func slideStartWith(_ timeInterval: TimeInterval) {
        isSliding = true
        scrollView.canCancelContentTouches = false
        scrollView.delaysContentTouches = true
        navigationController?.navigationBar.isHidden = false
        slideTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(leftSlide), userInfo: nil, repeats: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        slideStartWith(slideSecond[indexPath.row])
        dismissSlideContainView()
    }
    
    func setupContainView() {
        slideSecondTableView.layer.cornerRadius = 10
        btnCancel.layer.cornerRadius = 10
    }
    
    func addConstraintsForContainView() {
        let leadingConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: slideTimeChoiceConatinView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 15)
        let trailingConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: slideTimeChoiceConatinView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -15)
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: slideTimeChoiceConatinView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: slideTimeChoiceConatinView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 460)
        view.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint])
    }
    
    func removeConstraintsForContainView() {
        view.constraints.map({
            if let view = $0.firstItem as? UIStackView, view == slideTimeChoiceConatinView {
                view.removeConstraint($0)
            }
        })
    }
    
    func dismissSlideContainView() {
        removeConstraintsForContainView()
        slideTimeChoiceConatinView.translatesAutoresizingMaskIntoConstraints = true
        slideTimeChoiceConatinView.frame = CGRect.init(x: 15, y: scrollViewHeight - containViewHeight, width: scrollViewWidth-30, height: containViewHeight)
        UIView.animate(withDuration: 0.3,
                              delay: 0,
                            options: .curveEaseOut,
                         animations: {
            self.slideTimeChoiceConatinView.frame = CGRect.init(x: 15, y: self.scrollViewHeight, width: self.scrollViewWidth-30, height: self.containViewHeight)
        },
                         completion: { isCompleted in
            self.slideTimeChoiceConatinView.removeFromSuperview()
        })
    }
    
    @IBAction func cancelClicked() {
        dismissSlideContainView()
    }
}

extension PHAsset {
    var originalFilename: String? {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
}

//extension AVPhotoViewController: PHPhotoLibraryChangeObserver {
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        guard let change = changeInstance.changeDetails(for: asset), let updatedAsset = change.objectAfterChanges else { return }
//        
//        DispatchQueue.main.sync {
//            asset = updatedAsset
//            imageView.fetchImageAsset(
//                asset,
//                targetSize: view.bounds.size
//            ) { [weak self] _ in
//                guard let self = self else { return }
//                self.updateFavoriteButton()
//                self.updateUndoButton()
//            }
//        }
//    }
//}
