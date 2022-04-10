//
//  AVAlblumCollectionViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/4.
//

import Foundation
import UIKit
import Photos

class AVAlbumCollectionViewController : UICollectionViewController {
    var allPhotos = PHFetchResult<PHAsset>()
    var smartAlbums = PHFetchResult<PHAssetCollection>()
    var userAssetsArr = [PHFetchResult<PHAsset>].init()
    
    var userCollections = PHFetchResult<PHAssetCollection>()
    
    func fetchAssets() {
        fetchAllPhotosAssets()
        fetchUserAssets()
    }
    
    func fetchAllPhotosAssets() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(
                key: "creationDate",
          ascending: false)
        ]
        
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
    }
    
    func fetchUserAssets() {
        userCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for index in 0..<userCollections.count {
            let collection = userCollections[index]
            let fetchedAssets = PHAsset.fetchAssets(in: collection, options: nil)
            
            if fetchedAssets.count != 0 {
                userAssetsArr.append(fetchedAssets)
            }
        }
    }
    
    func getPermissionIfNecessary(completeHandler: @escaping (Bool) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completeHandler(true)
            return
        }
        
        PHPhotoLibrary.requestAuthorization({ status in
            completeHandler(status == .authorized ? true : false)
        })
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPermissionIfNecessary(completeHandler: { granted in
            guard granted else { return }
            self.fetchAssets()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
        setupCollectionView()
        setupNavigationItem()
        PHPhotoLibrary.shared().register(self)
    }
    
    func setupNavigationItem() {
        navigationItem.title = "相册"
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "照片", style: .plain, target: nil, action: nil)
    }
    
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout.init()
        
        let width = (view.bounds.size.width - 35) / 3
        
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.itemSize = CGSize.init(width: width, height: width+15)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 10, left: 15, bottom: 10, right: 10)
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userAssetsArr.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AVAlbumCollectionViewCell.reuseIdentifier, for: indexPath) as? AVAlbumCollectionViewCell else {
            fatalError("Unable to dequeue AVAlbumCollectionViewCell")
        }
        
        let row = indexPath.row
        var coverAsset: PHAsset?
        
        if row == 0 {
            coverAsset = allPhotos.firstObject
            cell.update(title: "最近访问")
        }else {
            let albumTitle = userCollections.object(at: row-1).localizedTitle
            coverAsset = userAssetsArr[row-1].firstObject
            cell.update(title: albumTitle)
        }
        
        guard let asset = coverAsset else { return cell }
        cell.photoView.fetchImageAsset(asset, targetSize: cell.bounds.size, completionHandler: { success in
            
        })
        
        return cell
    }
    
    @IBSegueAction func makeAVPhotosCollectionViewController(_ coder: NSCoder) -> AVPhotosCollectionViewController? {
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first
        else { return nil}
        
        let assets: PHFetchResult<PHAsset>
        let title: String
        
        let row = selectedIndexPath.row
        if row == 0 {
            assets = allPhotos
            title = "最近访问"
        }else {
            assets = userAssetsArr[row-1]
            title = userCollections.object(at: row-1).localizedTitle!
        }
        
        return AVPhotosCollectionViewController.init(assets: assets, title: title, coder: coder)
    }
}

extension AVAlbumCollectionViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                allPhotos = changeDetails.fetchResultAfterChanges
            }
            
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
            }
            
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
            }
            
            collectionView.reloadData()
        }
    }
}
