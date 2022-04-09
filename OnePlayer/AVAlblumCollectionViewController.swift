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
    
    var fetchResults: Array<PHFetchResult<PHAsset>> {
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
            var titles: Array<String> = []
            
            titles.append("最近访问")
            for index in 0..<albumList.count {
                titles.append(albumList.object(at: index).localizedTitle!)
            }
            
            return titles
        }
    }
    
    var albumsThumbnail: Array<UIImage> {
        get {
            var thumbnails: Array<UIImage> = []
            
            let manager = PHImageManager.default()
            let assets = fetchResults.map( {$0.firstObject})
            for asset in assets {
                manager.requestImage(for: asset!,
                              targetSize: PHImageManagerMaximumSize,
                             contentMode: .aspectFill,
                                 options: PHImageRequestOptions.init(),
                           resultHandler: { (image, hashable) in
                    thumbnails.append(image!)
                })
            }
            
            return thumbnails
        }
    }
    
    var assetCollection: PHFetchResult<PHAsset>!
    var albumTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationItem()
    }
    
    func setupNavigationItem() {
        self.navigationItem.title = "相册"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "照片", style: .plain, target: nil, action: nil)
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
        return fetchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as? AVAlbumCollectionViewCell else {
            return UICollectionViewCell.init()
        }
        
        cell.thumbnail.image = albumsThumbnail[indexPath.row]
        cell.thumbnail.layer.cornerRadius = 8
        cell.lblAlbumTitle.text = albumsTitle[indexPath.row]
        
        return cell
    }
    
    func getAssetFrom(_ fetchResult: PHFetchResult<PHAsset>) -> Array<PHAsset> {
        var result: Array<PHAsset> = []
        
        for index in 0..<self.assetCollection.count {
            result.append(self.assetCollection.object(at: index))
        }
        
        return result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoCollectionViewController = segue.destination as? AVPhotoCollectionViewController else {
            return
        }
        
        photoCollectionViewController.assets = getAssetFrom(self.assetCollection)
        photoCollectionViewController.albumTitle = self.albumTitle
        
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.assetCollection = self.fetchResults[indexPath.row]
        self.albumTitle = self.albumsTitle[indexPath.row]
        performSegue(withIdentifier: "showPhoto", sender: self)
    }
}
