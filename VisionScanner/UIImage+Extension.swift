//
//  UIImage+Extension.swift
//  VisionScanner
//
//  Created by Alfian Losari on 02/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit

extension UIImage {
    
    var base64EncodedString: String {
        var imageData = UIImagePNGRepresentation(self)!
        if (imageData.count > 2097152) {
            let oldSize = size
            let newSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imageData = resizeImage(size: newSize)
        }
        return imageData.base64EncodedString(options: .endLineWithCarriageReturn)
        
    }
    
    func resizeImage(size: CGSize) -> Data {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        let resizedImage = UIImagePNGRepresentation(newImage)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    var orientedUpImage: UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
    
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
        
    }
    
    
}

