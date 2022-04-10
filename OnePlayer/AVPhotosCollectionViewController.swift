//
//  AVPhotoCollectionViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/5.
//

import Foundation
import UIKit
import Photos

class AVPhotosCollectionViewController: UICollectionViewController {
    
    let cacheImageManager: PHCachingImageManager = PHCachingImageManager.init()
    
    var requestImageOptions: PHImageRequestOptions {
        get {
            let result: PHImageRequestOptions = PHImageRequestOptions.init()
            result.deliveryMode = .highQualityFormat
            return result
        }
    }
    
    var assets: PHFetchResult<PHAsset>!
    
    var didSelectedIndex: Int!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init?(assets: PHFetchResult<PHAsset>, title: String, coder: NSCoder) {
      self.assets = assets
      super.init(coder: coder)
      self.title = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItem()
    }
    
    
    func setupNavigationItem() {
        navigationItem.title = title
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
        return assets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AVPhotoCollectionViewCell.reuseIdentifier, for: indexPath) as? AVPhotoCollectionViewCell else {
            fatalError("Unable to dequeue AVPhotoCollectionViewCell")
        }
        
        let asset = assets[indexPath.row]
        cell.update(title: asset.originalFilename, creationDate: asset.creationDate)
        cell.photoView.fetchImageAsset(asset, targetSize: cell.bounds.size, completionHandler: nil)
        
        return cell
    }
    
    @IBSegueAction func makeAVPhotoViewController(_ coder: NSCoder) -> AVPhotoViewController? {
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else {
            return nil
        }
        
        return AVPhotoViewController.init(assets: assets, index: selectedIndexPath.row, coder: coder)
    }

}

extension AVPhotosCollectionViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
      
        guard let change = changeInstance.changeDetails(for: assets) else {
            return
        }
        
        DispatchQueue.main.sync {
            assets = change.fetchResultAfterChanges
            collectionView.reloadData()
        }
    }
}


