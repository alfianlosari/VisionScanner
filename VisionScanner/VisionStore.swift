//
//  VisionStore.swift
//  VisionScanner
//
//  Created by Alfian Losari on 02/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import Foundation
import UIKit

typealias AnnotateImageResponse =  (label: String?, ocr: String?, face: String?)

struct VisionStore {
    
    private init() {}
    
    fileprivate static let baseURL = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyBkw0rWFkiT4Z51Cxsb_-_PA6hnFXchFlE")!
    
    static func postScan(imageData: String, completionHandler: @escaping (_ data: AnnotateImageResponse?, _ error: Error?) -> Void) {
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonRequest: [String: Any] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 10
                    ],
                    
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: jsonRequest, options: [])
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                DispatchQueue.main.async { completionHandler(nil, error) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
                let error = NSError(domain: "Search Photo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Search Photo Failed."])
                DispatchQueue.main.async { completionHandler(nil, error) }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                if let errorJson = json["error"] as? [String: Any] {
                    let error = NSError(domain: "Post Scan", code: errorJson["code"] as? Int ?? 0, userInfo: [NSLocalizedDescriptionKey: errorJson["message"] as? String ?? "Scan Failed"])
                    DispatchQueue.main.async { completionHandler(nil, error) }
                    return
                }
                
                let responses = json["responses"] as! [[String: Any]]
                let response = responses[0]
                var faceText: String?
                var ocrText: String?
                var labelText: String?
                
                if let faceAnnotations = response["faceAnnotations"] as? [[String: Any]], !faceAnnotations.isEmpty {
                    let emotions = ["joy", "sorrow", "surprise", "anger"]
                    let numPeopleDetected = faceAnnotations.count
                    var text = "People detected: \(numPeopleDetected)\n\nEmotions detected:\n"
                    
                    var emotionTotals: [String: Double] = ["sorrow": 0, "joy": 0, "surprise": 0, "anger": 0]
                    var emotionLikelihoods: [String: Double] = ["VERY_LIKELY": 0.9, "LIKELY": 0.75, "POSSIBLE": 0.5, "UNLIKELY":0.25, "VERY_UNLIKELY": 0.0]
                    
                    outer: for index in 0..<numPeopleDetected {
                        let personData = faceAnnotations[index]
                        inner: for emotion in emotions {
                            let lookup = "\(emotion)Likelihood"
                            guard let result = personData[lookup] as? String else { continue inner }
                            emotionTotals[emotion]! += emotionLikelihoods[result]!
                        }
                    }
                    
                    for (emotion, total) in emotionTotals {
                        let likelihood = total / Double(numPeopleDetected)
                        let percent: Int = Int(round(likelihood * 100))
                        text += "\(emotion): \(percent)%\n"
                    }
                    
                    faceText = text
                    
                }
                
                if let labelAnnotations = response["labelAnnotations"] as? [[String: Any]], !labelAnnotations.isEmpty {
                    let numLabels = labelAnnotations.count
                    var labels = [String]()
                    var text = "Labels found: "
                    for index in 0..<numLabels {
                        let dict = labelAnnotations[index]
                        guard let description = dict["description"] as? String else { continue }
                        labels.append(description)
                    }
                    
                    for label in labels {
                        if labels[labels.count - 1] != label {
                            text += "\(label), "
                        } else {
                            text += "\(label)"
                        }
                    }
                    labelText = text
                }
                
                if let textAnnotations = response["textAnnotations"] as? [[String: Any]], !textAnnotations.isEmpty {
                    if let ocr = textAnnotations[0]["description"] as? String {
                        ocrText = ocr
                    }
                }
                
                DispatchQueue.main.async {
                    completionHandler((labelText, ocrText, faceText), nil)
                }
                
                
                
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
            
        }
        
        task.resume()
        
    }
}
