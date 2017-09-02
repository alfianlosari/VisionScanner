//
//  UIViewPrintFormatter+Extension.swift
//  VisionScanner
//
//  Created by Alfian Losari on 02/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit

extension UIViewPrintFormatter {
    
    func generatePDF(html: String, filename: String) -> URL {
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(self, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        
        for i in 1...render.numberOfPages {
            
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("vision.pdf")
        try! pdfData.write(to: url)
        return url
    }
    
    
}

