//
//  Vision+Extension.swift
//  VisionScanner
//
//  Created by Alfian Losari on 02/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import CoreData
import UIKit

extension Vision {
    
    static func insert(imageData: Data, thumbnailImageData: Data, labelText: String?, ocrText: String?, faceText: String?, moc: NSManagedObjectContext) -> Vision {
        let vision = NSEntityDescription.insertNewObject(forEntityName: "Vision", into: moc) as! Vision
        vision.createdAt = NSDate()
        vision.imageData = imageData as NSData
        vision.thumbnailImageData = imageData as NSData
        vision.labelText = labelText
        vision.ocrText = ocrText
        vision.faceText = faceText
        
        return vision
    }
    
    var image: UIImage {
        return UIImage(data: imageData! as Data)!
    }
    
    var subtitleText: String {
        var text = ""
        if let _ = labelText {
            text += "LABELS, "
        }
        
        if let _ = faceText {
            text += "FACES, "
        }
        
        if let _ = ocrText {
            text += "OCR"
        }
        
        if text.isEmpty {
            text += "No Analysis found"
        }
        
        return text
        
    }
    
    var markupText: String{
        
        var text = "<html><body><h1>Vision Scanner</h1><div style=\"max-width:200px\"><img src=\"data:image/png;base64,\(image.base64EncodedString)\" style=\"max-width:100%;height: auto;\"/></div>"
        text += "<h3>Labels</h3>"
        if let labelText = labelText {
            text += "<p>\(labelText)</p>"
        } else {
            text += "<p>No results for Labels</p>"
        }
        
        text += "<h3>Faces</h3>"

        if let faceText = faceText {
            text += "<p>\(faceText)</p>"
        } else {
            text += "<p>No results for Faces</p>"
        }
        
        text += "<h3>OCR Text</h3>"
        if let ocrText = ocrText {
            text += "<p>\(ocrText)</p>"
        } else {
            text += "<p>No results for OCR</p>"
        }
        return text
    }
    
    
}

