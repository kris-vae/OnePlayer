//
//  AVPhotoSlideViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/6.
//

import Foundation
import UIKit

class AVPhotoSlideViewController: UIViewController, UIScrollViewDelegate {
    
    var slidePhotos: Array<UIImage>!
    var photosTitle: Array<String>!

    var photoTotalNumber: Int {
        get {
            return photosTitle.count
        }
    }
    
    var currentPhotoIndex: Int!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
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
    
    func initializeView() {
        self.scrollView = initializeScrollView()
        
        self.leftImgView = self.initializeImgView()
        self.scrollView.addSubview(self.leftImgView)
        
        if self.photoTotalNumber == 1 {
            self.leftImgView.image = self.slidePhotos[self.currentPhotoIndex]
        }else {
            self.middleImgView = self.initializeImgView()
            self.middleImgView.image = self.slidePhotos[self.currentPhotoIndex]
            self.rightImgView = self.initializeImgView()
            self.scrollView.addSubview(self.middleImgView)
            self.scrollView.addSubview(self.rightImgView)
        }
       
        self.addConstraints()
        self.view.addSubview(self.scrollView)
        
        self.didInitializeView = true
    }
    
    func updateImageView() {
        if self.currentPhotoIndex == 0 {
            self.leftImgView.image = slidePhotos[photoTotalNumber-1]
            self.middleImgView.image = slidePhotos[self.currentPhotoIndex]
            self.rightImgView.image = slidePhotos[self.currentPhotoIndex+1]
        }else if self.currentPhotoIndex == photoTotalNumber - 1{
            self.leftImgView.image = slidePhotos[self.currentPhotoIndex-1]
            self.middleImgView.image = slidePhotos[self.currentPhotoIndex]
            self.rightImgView.image = slidePhotos[0]
        }else {
            self.leftImgView.image = slidePhotos[self.currentPhotoIndex-1]
            self.middleImgView.image = slidePhotos[self.currentPhotoIndex]
            self.rightImgView.image = slidePhotos[self.currentPhotoIndex+1]
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGFloat = self.scrollView.contentOffset.x
        
        if offset >= self.scrollViewWidth * 2 && photoTotalNumber != 1{
            self.scrollView.contentOffset = CGPoint.init(x: self.scrollViewWidth, y: 0)
            self.currentPhotoIndex = self.currentPhotoIndex + 1 == self.photoTotalNumber ? 0 : self.currentPhotoIndex + 1
        } else if offset <= 0 && photoTotalNumber != 1{
            self.scrollView.contentOffset = CGPoint.init(x: self.scrollViewWidth, y: 0)
            self.currentPhotoIndex = self.currentPhotoIndex - 1 < 0 ? photoTotalNumber-1 : self.currentPhotoIndex - 1
        }
        
        if self.didInitializeView && photoTotalNumber > 1{
            self.updateImageView()
        }
    }
}
