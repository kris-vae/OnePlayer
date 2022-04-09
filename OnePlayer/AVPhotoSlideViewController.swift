//
//  AVPhotoSlideViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/6.
//

import Foundation
import UIKit
import Photos

class AVPhotoSlideViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{
    
    var slideImages: Array<UIImage?>!
    
    var photosTitle: Array<String> {
        get {
            var result: Array<String> = []
            
            for asset in self.assets {
                result.append(asset.localIdentifier)
            }
            
            return result
        }
    }
    var assets: Array<PHAsset>!
    
    var photoTotalNumber: Int {
        get {
            return self.assets.count
        }
    }
    
    var currentPhotoIndex: Int! {
        didSet {
            self.navigationItem.title = String.init(format: "%@(%@/%@)", self.photosTitle[self.currentPhotoIndex], String(Int(self.currentPhotoIndex)), String(self.photoTotalNumber))
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
        self.initializeView()
        self.setupNavigationBarUI()
        self.addTouchEvent()
        self.tabBarController?.tabBar.isHidden = true
        self.slideTimeChoiceConatinView.removeFromSuperview()
    }
    
    func setupNavigationBarUI() {
        self.navigationItem.title = String.init(format: "%@(%@/%@)", self.photosTitle[self.currentPhotoIndex], String(Int(self.currentPhotoIndex)), String(self.photoTotalNumber))
    }
    
    func addTouchEvent() {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(changeStatus))
        tapGestureRecognizer.delegate = self
        self.scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func changeStatus() {
        if self.isSliding {
            self.isSliding = false
            self.slideTimer.invalidate()
            self.slideTimer = nil
            self.navigationController?.navigationBar.isHidden = false
        }else {
            guard let isHidden = self.navigationController?.navigationBar.isHidden else {
                return
            }
            if self.slideTimeChoiceConatinView.superview == self.view {
                self.dismissSlideContainView()
                self.navigationController?.navigationBar.isHidden = false
            }else {
                self.navigationController?.navigationBar.isHidden = !isHidden
            }
        }
    }
    
    func initializeImgView() -> UIImageView {
        let imgView: UIImageView = UIImageView.init()
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        
        let imgViewWidthConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: imgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.scrollViewWidth)
        let imgViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: imgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.scrollViewHeight)
        
        imgView.addConstraints([imgViewWidthConstraint, imgViewHeightConstraint])
        
        return imgView
    }
    
    func initializeScrollView() -> UIScrollView {
        let scrollView: UIScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.scrollViewWidth, height: self.scrollViewHeight))
    
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        if photoTotalNumber == 1 {
            scrollView.contentSize = CGSize.init(width: self.scrollViewWidth+20, height: self.scrollViewHeight)
            scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        }else {
            scrollView.contentSize = CGSize.init(width: self.scrollViewWidth*3, height: self.scrollViewHeight)
            scrollView.contentOffset = CGPoint.init(x: self.scrollViewWidth, y: 0)
        }
        
        return scrollView
    }
    
    func addConstraints() {
        self.scrollView.addConstraint(NSLayoutConstraint.init(item: self.leftImgView, attribute: .centerX, relatedBy: .equal, toItem: self.scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        self.scrollView.addConstraint(NSLayoutConstraint.init(item: self.leftImgView, attribute: .centerY, relatedBy: .equal, toItem: self.scrollView, attribute: .centerY, multiplier: 1, constant: 0))
        
        if self.photoTotalNumber > 1 {
            self.scrollView.addConstraint(NSLayoutConstraint.init(item: self.middleImgView, attribute: .leading, relatedBy: .equal, toItem: self.leftImgView, attribute: .trailing, multiplier: 1, constant: 0))
            self.scrollView.addConstraint(NSLayoutConstraint.init(item: self.middleImgView, attribute: .centerY, relatedBy: .equal, toItem: self.scrollView, attribute: .centerY, multiplier: 1, constant: 0))
            
            self.scrollView.addConstraint(NSLayoutConstraint.init(item: self.rightImgView, attribute: .leading, relatedBy: .equal, toItem: self.middleImgView, attribute: .trailing, multiplier: 1, constant: 0))
            self.scrollView.addConstraint(NSLayoutConstraint.init(item: self.rightImgView, attribute: .centerY, relatedBy: .equal, toItem: self.scrollView, attribute: .centerY, multiplier: 1, constant: 0))
        }
    }
    
    func addSubViews() {
        self.scrollView.addSubview(self.leftImgView)
        
        if self.photoTotalNumber > 1 {
            self.scrollView.addSubview(self.middleImgView)
            self.scrollView.addSubview(self.rightImgView)
        }
        self.view.addSubview(self.scrollView)
    }
    
    func initializeView() {
        self.scrollView = initializeScrollView()
        self.leftImgView = self.initializeImgView()
        
        if self.photoTotalNumber == 1 {
            self.setImageFor(imageView: self.leftImgView, atAssetIndex: self.currentPhotoIndex)
        }else {
            self.middleImgView = self.initializeImgView()
            self.setImageFor(imageView: self.middleImgView, atAssetIndex: self.currentPhotoIndex)
            self.rightImgView = self.initializeImgView()
          
        }
       
        self.addSubViews()
        self.addConstraints()
        
        self.didInitializeView = true
    }
    
    func setImageFor(imageView: UIImageView, atAssetIndex index: Int) {
        if let image = slideImages[index] {
            imageView.image = image
            return
        }
        
        let asset = self.assets[index]
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: { (result, _) in
            imageView.image = result
            self.slideImages[index] = result
        })
    }
    
    func updateImageView() {
        if self.currentPhotoIndex == 0 {
            self.setImageFor(imageView: self.leftImgView, atAssetIndex: self.photoTotalNumber-1)
            self.setImageFor(imageView: self.middleImgView, atAssetIndex: self.currentPhotoIndex)
            self.setImageFor(imageView: self.rightImgView, atAssetIndex: self.currentPhotoIndex+1)
        }else if self.currentPhotoIndex == photoTotalNumber - 1{
            self.setImageFor(imageView: self.leftImgView, atAssetIndex: self.currentPhotoIndex-1)
            self.setImageFor(imageView: self.middleImgView, atAssetIndex: self.currentPhotoIndex)
            self.setImageFor(imageView: self.rightImgView, atAssetIndex: 0)
        }else {
            self.setImageFor(imageView: self.leftImgView, atAssetIndex: self.currentPhotoIndex-1)
            self.setImageFor(imageView: self.middleImgView, atAssetIndex: self.currentPhotoIndex)
            self.setImageFor(imageView: self.rightImgView, atAssetIndex: self.currentPhotoIndex+1)
        }
    }
    
    func setupScrollView() {
        if self.didInitializeView && self.photoTotalNumber > 1 {
            let offset: CGFloat = self.scrollView.contentOffset.x
            
            if offset >= self.scrollViewWidth * 2 {
                self.scrollView.contentOffset = CGPoint.init(x: self.scrollViewWidth, y: 0)
                self.currentPhotoIndex = self.currentPhotoIndex + 1 == self.photoTotalNumber ? 0 : self.currentPhotoIndex + 1
            }else if offset <= 0 {
                self.scrollView.contentOffset = CGPoint.init(x: self.scrollViewWidth, y: 0)
                self.currentPhotoIndex = self.currentPhotoIndex - 1 < 0 ? photoTotalNumber-1 : self.currentPhotoIndex - 1
            }
            self.updateImageView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setupScrollView()
    }
    
    @IBAction func dismissClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func slideClicked() {
        self.view.addSubview(self.slideTimeChoiceConatinView)
        self.slideTimeChoiceConatinView.translatesAutoresizingMaskIntoConstraints = false
        self.slideTimeChoiceConatinView.frame.origin = CGPoint.init(x: 0, y: self.scrollViewHeight)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.slideTimeChoiceConatinView.frame.origin = CGPoint.init(x: 0, y: self.scrollViewHeight-self.containViewHeight)
        })
        
        self.addConstraintsForContainView()
        self.setupContainView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.slideSecond.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.slideSecondTableView.dequeueReusableCell(withIdentifier: "slideSecond") as? AVSlidePhotoTimeTableViewCell else {
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
        self.isSliding = true
        self.scrollView.canCancelContentTouches = false
        self.scrollView.delaysContentTouches = true
        self.navigationController?.navigationBar.isHidden = false
        self.slideTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(leftSlide), userInfo: nil, repeats: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.slideStartWith(self.slideSecond[indexPath.row])
        self.dismissSlideContainView()
    }
    
    func setupContainView() {
        self.slideSecondTableView.layer.cornerRadius = 10
        self.btnCancel.layer.cornerRadius = 10
    }
    
    func addConstraintsForContainView() {
        let leadingConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self.slideTimeChoiceConatinView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 15)
        let trailingConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self.slideTimeChoiceConatinView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -15)
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self.slideTimeChoiceConatinView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self.slideTimeChoiceConatinView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 460)
        self.view.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint])
    }
    
    func removeConstraintsForContainView() {
        self.view.constraints.map({
            if let view = $0.firstItem as? UIStackView, view == self.slideTimeChoiceConatinView {
                self.view.removeConstraint($0)
            }
        })
    }
    
    func dismissSlideContainView() {
        self.removeConstraintsForContainView()
        self.slideTimeChoiceConatinView.translatesAutoresizingMaskIntoConstraints = true
        self.slideTimeChoiceConatinView.frame = CGRect.init(x: 15, y: self.scrollViewHeight - self.containViewHeight, width: self.scrollViewWidth-30, height: self.containViewHeight)
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
        self.dismissSlideContainView()
    }
}
