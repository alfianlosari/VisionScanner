//
//  VisionDetailViewController.swift
//  VisionScanner
//
//  Created by Alfian Losari on 01/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit
import CoreData
import WebKit

class VisionDetailViewController: UIViewController, UIPrintInteractionControllerDelegate {
    
    var vision: Vision!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var overlayView: UIView!
    
    // Helper to generate PDF data for sharing
    var webView: WKWebView = WKWebView()
    var htmlText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        imageView.image =  UIImage(data: vision.imageData! as Data)
        updateTextView(scanType: segmentedControl.scanType)
    }

    fileprivate func updateTextView(scanType: ScanType) {
        switch scanType {
        case .label:
            textView.text = vision.labelText ?? "No results found for Label"
            
        case .face:
            textView.text = vision.faceText ?? "No results found for Face"
            
        case .ocr:
            textView.text = vision.ocrText ?? "No results found for OCR"
            
        }
    }
    
    @IBAction func deleteVision(_ sender: Any) {
        guard let vision = vision,
            let moc = vision.managedObjectContext else { return }
        moc.delete(vision)
        do {
            try moc.save()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            showAlert(title: nil, message: error.localizedDescription)
        }
        
    }
    
    func showActivityIndicator(showing: Bool) {
        overlayView.isHidden = showing ? false : true
        view.isUserInteractionEnabled = showing ? false : true
    }
    
    @IBAction func shareVision(_ sender: Any) {
        // Load html text to webview to render PDF
        showActivityIndicator(showing: true)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let markupText = self?.vision.markupText ?? ""
            self?.htmlText = markupText
            DispatchQueue.main.async {
                self?.webView.loadHTMLString(markupText, baseURL: nil)
            }
        }

    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        updateTextView(scanType: segmentedControl.scanType)
    }
    
}


extension VisionDetailViewController: WKNavigationDelegate {

    // PDF has finished rendering with image
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let htmlText = self.htmlText
        else { return }
        let url = webView.viewPrintFormatter().generatePDF(html: htmlText, filename: "vision")
        showActivityIndicator(showing: false)
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }

}

fileprivate enum ScanType {
    case label
    case face
    case ocr
}

fileprivate extension UISegmentedControl {
    
    var scanType: ScanType {
        switch selectedSegmentIndex {
        case 0:
            return .label
            
        case 1:
            return .face
            
        case 2:
            return .ocr
            
        default:
            fatalError("Invalid Index")
        }
    }
    
    
}
