//
//  AVPhotoCollectionViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/5.
//

import Foundation
import UIKit
import Photos

class AVPhotoCollectionViewController: UICollectionViewController {
    
    let cacheImageManager: PHCachingImageManager = PHCachingImageManager.init()
    
    var requestImageOptions: PHImageRequestOptions {
        get {
            let result: PHImageRequestOptions = PHImageRequestOptions.init()
            result.deliveryMode = .highQualityFormat
            return result
        }
    }
    
    var assets: Array<PHAsset>! {
        didSet {
            cacheImageManager.stopCachingImages(for: self.assets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: self.requestImageOptions)
        }
        
        willSet {
            cacheImageManager.stopCachingImagesForAllAssets()
        }
    }
    
    var albumTitle: String!
    var didSelectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItem()
    }
    
    func setupNavigationItem() {
        self.navigationItem.title = albumTitle
    }
    
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout.init()
        
        let width = (view.bounds.size.width - 35) / 3
        
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.itemSize = CGSize.init(width: width, height: width+60)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 10, left: 15, bottom: 10, right: 10)
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? AVPhotoCollectionViewCell else {
            return UICollectionViewCell.init()
        }
        
        let manager: PHImageManager = PHImageManager.default()
        
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        let asset: PHAsset = assets[indexPath.row]
        
        if let createDate = asset.creationDate {
            cell.lblCreateDate.text = createDate.dateToString()
        }else {
            cell.lblCreateDate.text = nil
        }
        
        cell.lblPhotoTitle.text = asset.localIdentifier
        
        cell.tag = Int(manager.requestImage(for: asset,
                                     targetSize: PHImageManagerMaximumSize,
                                    contentMode: .aspectFill,
                                        options: self.requestImageOptions,
                                  resultHandler: {(result, _) in
            cell.thumbnail.image = result
        }))
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoSlideViewController = segue.destination as? AVPhotoSlideViewController else {
            return
        }
        photoSlideViewController.assets = self.assets
        photoSlideViewController.currentPhotoIndex = self.didSelectedIndex
        photoSlideViewController.slideImages = Array.init(repeating: nil, count: self.assets.count)
       
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectedIndex = indexPath.row
        performSegue(withIdentifier: "showSlidePhoto", sender: self)
    }
}

extension Date {
    func dateToString(dateFormat: String = "yyyy/MM/dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let dateStr = formatter.string(from: self)
        return dateStr
    }
}
