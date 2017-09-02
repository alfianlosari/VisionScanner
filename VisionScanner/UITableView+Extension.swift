//
//  UITableView+Extension.swift
//  VisionScanner
//
//  Created by Alfian Losari on 02/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit

extension UITableView {
    
    func setBackground(forMessage message: String?) {
        if let message = message {
            // Display a message when the table is empty
            DispatchQueue.main.async {
                let messageLabel = UILabel()
                
                messageLabel.text = message
                messageLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
                messageLabel.textColor = UIColor.lightGray
                messageLabel.textAlignment = .center
                messageLabel.numberOfLines = 3
                messageLabel.sizeToFit()
                
                self.backgroundView = messageLabel
                self.separatorStyle = .none
            }
    
            
            
        }
        else {
            DispatchQueue.main.async {
                self.backgroundView = nil
                self.separatorStyle = .singleLine
            }
        
        }
    }
    
}
