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
    var albumTitle: String!
    
    var photosAssset: Array<UIImage> {
        get {
            var photos: Array<UIImage> = []
            let manager = PHImageManager.default()
            for index in 0..<asssetConllection.count {
                let assset = asssetConllection.object(at: index)
                manager.requestImage(for: assset,
                                     targetSize: PHImageManagerMaximumSize,
                                     contentMode: .aspectFill,
                                     options: PHImageRequestOptions.init(),
                                     resultHandler: { (image, hashable) in
                    photos.append(image!)
                })
            }
            
            return photos
        }
    }
    
    var photosTitle: Array<String> {
        get {
            var titles: Array<String> = []
            for index in 0..<asssetConllection.count {
                titles.append(asssetConllection.object(at: index).localIdentifier)
            }
            
            return titles
        }
    }
    
    var photosCreateDate: Array<String> {
        get {
            var date: Array<String> = []
            for index in 0..<asssetConllection.count {
                date.append((asssetConllection.object(at: index).creationDate?.dateToString())!)
            }
            
            return date
        }
    }
    
    var disSelectedIndex: Int!
    
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
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "照片", style: .plain, target: nil, action: nil)
        
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
        return asssetConllection.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? AVPhotoCollectionViewCell else {
            return UICollectionViewCell.init()
        }
        
        cell.imgThumbnail.image = photosAssset[indexPath.row]
        cell.lblPhotoTitle.text = photosTitle[indexPath.row]
        cell.lblCreateDate.text = photosCreateDate[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoSlideViewController = segue.destination as? AVPhotoSlideViewController else {
            return
        }
        
        photoSlideViewController.currentPhotoIndex = self.disSelectedIndex
        photoSlideViewController.slidePhotos = self.photosAssset
        photoSlideViewController.photosTitle = self.photosTitle
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.disSelectedIndex = indexPath.row
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
