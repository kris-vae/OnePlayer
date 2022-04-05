//
//  AVAlblumCollectionViewController.swift
//  OnePlayer
//
//  Created by kris on 2022/4/4.
//

import Foundation
import UIKit
import Photos

class AVAlblumCollectionViewController : UICollectionViewController {
    
    var albumList: PHFetchResult<PHAssetCollection> {
        get {
            return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        }
    }
    
    var fetchResult: Array<PHFetchResult<PHAsset>> {
        get {
            var result: Array<PHFetchResult<PHAsset>> = []
            
            result.append(PHAsset.fetchAssets(with: PHFetchOptions.init()))
            for index in 0..<albumList.count {
                result.append(PHAsset.fetchAssets(in: albumList.object(at: index), options: .none))
            }
            
            return result
        }
    }
    
    var albumsTitle: Array<String> {
        get {
            var title: Array<String> = []
            
            title.append("最近访问")
            for index in 0..<albumList.count {
                title.append(albumList.object(at: index).localIdentifier)
            }
            
            return title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout.init()
        let width = (view.bounds.size.width - 50) / 3
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 16.0
        
        flowLayout.itemSize = CGSize.init(width: width, height: width)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 10, left: 15, bottom: 10, right: 15)
        collectionView.collectionViewLayout = flowLayout
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumList.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as? AVAlbumCollectionViewCell else {
            return UICollectionViewCell.init()
        }
        
        let assset: PHAsset = fetchResult[indexPath.row].firstObject!
//
//        if indexPath.row == 0 {
////            let allPhotos = PHAsset.fetchAssets(with: PHFetchOptions.init())
//            assset = fetchResult[indexPath.row].firstObject
//            cell.lblAlbumTitle.text = "最近项目"
//        }else {
////            let album = albumList.object(at: indexPath.row - 1)
//            assset = fetchResult[indexPath.row].firstObject
//            cell.lblAlbumTitle.text = album.localizedTitle
//        }
        
        let manager = PHImageManager.default()
        manager.requestImage(for: assset,
                      targetSize: PHImageManagerMaximumSize,
                     contentMode: .aspectFill,
                         options: PHImageRequestOptions.init(),
                   resultHandler: { (image, hashable) in
            cell.imgThumbnail.image = image
        })
        
        cell.lblAlbumTitle.text = albumsTitle[indexPath.row]
        print(albumsTitle)
        cell.imgThumbnail.layer.cornerRadius = 8
        return cell
    }
}
