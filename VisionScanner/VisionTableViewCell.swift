//
//  VisionTableViewCell.swift
//  VisionScanner
//
//  Created by Alfian Losari on 02/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit



class VisionTableViewCell: UITableViewCell {
    
    static let dateFormatter: DateFormatter = {
        $0.dateStyle = .short
        $0.timeStyle = .short
        return $0
    }(DateFormatter())
    
    @IBOutlet weak var visionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    func setup(vision: Vision) {
        visionImageView?.image =  UIImage(data: vision.thumbnailImageData! as Data)
        titleLabel.text = VisionTableViewCell.dateFormatter.string(from: vision.createdAt! as Date)
        
        subtitleLabel.text = vision.subtitleText
        
    }
}
