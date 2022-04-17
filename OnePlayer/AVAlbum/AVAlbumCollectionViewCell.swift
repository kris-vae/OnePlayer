//
//  AVAlbumCollectionViewCell.swift
//  OnePlayer
//
//  Created by kris on 2022/4/5.
//

import Foundation
import UIKit

class AVAlbumCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "albumCell"
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.layer.cornerRadius = 8
        photoView.image = nil
        albumTitle.text = "Untitled"
    }
    
    func update(title: String?) {
        albumTitle.text = title ?? "Untitled"
    }
}
