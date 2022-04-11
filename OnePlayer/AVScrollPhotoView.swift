//
//  AVSlidePhotoViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/11.
//

import Foundation
import UIKit

class AVScrollPhotoView : UIView, UIScrollViewDelegate {
    var scrollView: UIScrollView = UIScrollView.init()
    
    var leftImgView: UIImageView = UIImageView.init()
    var middleImgView: UIImageView = UIImageView.init()
    var rightImgView: UIImageView = UIImageView.init()
    
    var photoNumber: Int
    
    let scrollViewWidth = UIScreen.main.bounds.width
    let scrollViewHeight = UIScreen.main.bounds.height
    
    init(photoNumber: Int) {
        self.photoNumber = photoNumber
        super.init(frame: CGRect.init(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        
        self.scrollView = initializeScrollView()
        self.leftImgView = initializeImgView()
        self.middleImgView = initializeImgView()
        self.rightImgView = initializeImgView()
        
        setupSubViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        if photoNumber == 1 {
            scrollView.contentSize = CGSize.init(width: scrollViewWidth+20, height: scrollViewHeight)
            scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        }else {
            scrollView.contentSize = CGSize.init(width: scrollViewWidth*3, height: scrollViewHeight)
            scrollView.contentOffset = CGPoint.init(x: scrollViewWidth, y: 0)
        }
        
        return scrollView
    }
    
    func setupSubViewLayout() {
        addSubViews()
        addConstraints()
    }
    
    func addConstraints() {
       self.addConstraint(NSLayoutConstraint.init(item: leftImgView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: leftImgView, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1, constant: 0))
        
        if photoNumber > 1 {
            self.addConstraint(NSLayoutConstraint.init(item: middleImgView, attribute: .leading, relatedBy: .equal, toItem: leftImgView, attribute: .trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint.init(item: middleImgView, attribute: .centerY, relatedBy: .equal, toItem: leftImgView, attribute: .centerY, multiplier: 1, constant: 0))
            
            self.addConstraint(NSLayoutConstraint.init(item: rightImgView, attribute: .leading, relatedBy: .equal, toItem: middleImgView, attribute: .trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint.init(item: rightImgView, attribute: .centerY, relatedBy: .equal, toItem: leftImgView, attribute: .centerY, multiplier: 1, constant: 0))
        }
    }
    
    func addSubViews() {
        self.addSubview(scrollView)
        scrollView.addSubview(leftImgView)
        
        if photoNumber > 1 {
            scrollView.addSubview(middleImgView)
            scrollView.addSubview(rightImgView)
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if photoNumber > 1 {
            let offset: CGFloat = scrollView.contentOffset.x
            
            if offset >= scrollViewWidth * 2 {
                scrollView.contentOffset = CGPoint.init(x: scrollViewWidth, y: 0)
                NotificationCenter.default.post(name: .leftSlide, object: self)
            }else if offset <= 0 {
                scrollView.contentOffset = CGPoint.init(x: scrollViewWidth, y: 0)
                NotificationCenter.default.post(name: .rightSlide, object: self)
            }
            NotificationCenter.default.post(name: .updatePhoto, object: self)
        }
    }
}
