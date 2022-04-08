//
//  AVPhotoSlideViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/6.
//

import Foundation
import UIKit

class AVPhotoSlideViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{
    
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
    var noTouchTimer: Timer!
    
    @IBOutlet var slideTimeChoiceConatinView: UIStackView!
    let containViewHeight: CGFloat = 460
    @IBOutlet weak var slideSecondTableView: UITableView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    
    let slideSecond: Array<Int> = [1, 5, 10, 15, 20, 25, 30, 45, 60]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
        self.setupNavigationBarUI()
        self.addNoTouchTimerEvent()
        self.addTouchEvent()
        self.tabBarController?.tabBar.isHidden = true
        self.slideTimeChoiceConatinView.removeFromSuperview()
    }
    
    func setupNavigationBarUI() {
        self.navigationItem.title = String.init(format: "%@(%@/%@)", self.photosTitle[self.currentPhotoIndex], String(self.currentPhotoIndex), String(self.photoTotalNumber))
    }
    
    func addTouchEvent() {
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(resetNoTouchTimer)))
    }
    
    @objc func resetNoTouchTimer() {
        self.navigationController?.navigationBar.isHidden = false
        self.invalidateTimer()
        self.addNoTouchTimerEvent()
    }
    
    func addNoTouchTimerEvent() {
        self.noTouchTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hiddenNavigationBar), userInfo: self, repeats: false)
    }
    
    @objc func hiddenNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
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
            self.leftImgView.image = self.slidePhotos[self.currentPhotoIndex]
        }else {
            self.middleImgView = self.initializeImgView()
            self.middleImgView.image = self.slidePhotos[self.currentPhotoIndex]
            self.rightImgView = self.initializeImgView()
          
        }
       
        self.addSubViews()
        self.addConstraints()
        
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
    
    func invalidateTimer() {
        guard let timer = self.noTouchTimer else {
            return
        }
        
        timer.invalidate()
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
        self.resetNoTouchTimer()
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
        
        let leadingConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self.slideTimeChoiceConatinView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 15)
        let trailingConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self.slideTimeChoiceConatinView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -15)
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self.slideTimeChoiceConatinView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self.slideTimeChoiceConatinView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 460)
        self.view.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint])
        
        self.setupContainView()
        self.invalidateTimer()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.slideSecond.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.slideSecondTableView.dequeueReusableCell(withIdentifier: "slideSecond") as? AVSlidePhotoTimeTableViewCell else {
            return UITableViewCell.init()
        }
        
        cell.lblSecond.text = String.init(format: "%@s", String(slideSecond[indexPath.row]))
        
        return cell
    }
    
    func setupContainView() {
        self.slideSecondTableView.layer.cornerRadius = 10
        self.btnCancel.layer.cornerRadius = 10
    }
    
    func removeConstraintsForContainView() {
        self.view.constraints.map({
            if let view = $0.firstItem as? UIStackView, view == self.slideTimeChoiceConatinView {
                self.view.removeConstraint($0)
            }
        })
    }
    
    @IBAction func cancelClicked() {
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
            self.resetNoTouchTimer()
        })
    }
}
