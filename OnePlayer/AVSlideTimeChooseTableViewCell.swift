//
//  AVSlidePhotoTimeTableViewCell.swift
//  OnePlayer
//
//  Created by kris on 2022/4/7.
//

import Foundation
import UIKit

class AVSlideTimeChooseTableViewCell: UITableViewCell {
    static let reuseIdentifier = "slideSecondsCell"
    
    @IBOutlet weak var seconds: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.selectionStyle = .none
        seconds.text = "Undefined"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(_ second: Int) {
        self.seconds.text = String.init(format: "%@s", String(second))
    }
}
