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
    
    var asssetConllection: PHFetchResult<PHAsset>!
    var albumName: String!
    
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
        return asssetConllection.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? AVPhotoCollectionViewCell else {
            return UICollectionViewCell.init()
        }
        
        let assset = asssetConllection.object(at: indexPath.row)
        
        let manager = PHImageManager.default()
        manager.requestImage(for: assset,
                      targetSize: PHImageManagerMaximumSize,
                     contentMode: .aspectFill,
                         options: PHImageRequestOptions.init(),
                   resultHandler: { (image, hashable) in
            cell.imgThumbnail.image = image
        })
        
        cell.lblPhotoTitle.text = assset.localIdentifier
        cell.lblCreateDate.text = assset.creationDate?.dateToString()
        
        return cell
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
