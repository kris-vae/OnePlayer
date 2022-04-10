//
//  AVFetchAssetCollectionManager.swift
//  OnePlayer
//
//  Created by kris on 2022/4/9.
//

import Foundation
import Photos

class AVFecthAsssetCollectionManager {
    let cacheImageManager: PHCachingImageManager = PHCachingImageManager.init()
    
    static var albumList: PHFetchResult<PHAssetCollection> {
        get {
            return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        }
    }
    
    static var fetchresult: Array<PHFetchResult<PHAsset>>{
        get {
            let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
            var result: Array<PHFetchResult<PHAsset>> = []
            result.append(PHAsset.fetchAssets(with: PHFetchOptions.init()))
            for index in 0..<albumList.count {
                result.append(PHAsset.fetchAssets(in: albumList.object(at: index), options: .none))
            }
            
            return result
        }
    }
    
    var requestsImageOptions: PHImageRequestOptions {
        get {
            let result: PHImageRequestOptions = PHImageRequestOptions.init()
            result.deliveryMode = .highQualityFormat
            return result
        }
    }
    
    var albumFetchResult: Array<PHFetchResult<PHAssetCollection>>!
    
    var imageAssetMap: Dictionary<String, Array<PHAsset>>! {
        get {
            return nil
        }
    }
}
