//
//  AVPhotoCollectionViewCell.swift
//  OnePlayer
//
//  Created by kris on 2022/4/5.
//

import Foundation
import UIKit

class AVPhotoCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "photoCell"
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!
    @IBOutlet weak var photoCreateDate: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = nil
        photoTitle.text = "Untitled"
        photoCreateDate.text = "Unknow"
    }
    
    func update(title: String?, createDate: Date?) {
        photoTitle.text = title ?? "Untitled"
        photoCreateDate.text = createDate?.dateToString() ?? "Unknow"
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

