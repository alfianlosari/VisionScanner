//
//  HomeViewController.swift
//  VisionScanner
//
//  Created by Alfian Losari on 01/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit
import CoreData

fileprivate let reuseIdentifier = "Cell"
fileprivate let detailSegue = "Detail"

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController<Vision> = {
        let fr = NSFetchRequest<Vision>(entityName: "Vision")
        fr.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Vision.createdAt), ascending: true)
        ]
        fr.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.tableFooterView = UIView()
        updateView()
    }
    
    @IBAction func scan(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
            alertController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                let imagePickerVC = UIImagePickerController()
                imagePickerVC.sourceType = .camera
                imagePickerVC.delegate = self
                self.present(imagePickerVC, animated: true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
                let imagePickerVC = UIImagePickerController()
                imagePickerVC.sourceType = .photoLibrary
                imagePickerVC.delegate = self
                self.present(imagePickerVC, animated: true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
        } else {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
            present(imagePickerVC, animated: true, completion: nil)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func updateView() {
        let visionCount = fetchedResultsController.fetchedObjects?.count ?? 0
        if visionCount == 0 {
            tableView.setBackground(forMessage: "No Visions\nScan to Analyze Image Labels, Faces, Texts")
        } else {
            tableView.setBackground(forMessage: nil)
        }
    }
    
    func showActivityIndicator(showing: Bool) {
        overlayView.isHidden = showing ? false : true
        view.isUserInteractionEnabled = showing ? false : true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegue {
            guard let visionDetailVC = segue.destination as? VisionDetailViewController,
             let vision = sender as? Vision else {
                fatalError("Invalid View Controller")
            }
            visionDetailVC.vision = vision
        }
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VisionTableViewCell
        let vision = fetchedResultsController.object(at: indexPath)
        cell.setup(vision: vision)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vision = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: detailSegue, sender: vision)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let vision = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(vision)
            do {
                try managedObjectContext.save()
            } catch {
                self.showAlert(title: nil, message: error.localizedDescription)
            }
        }
    }
    
    
}

extension HomeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)?.orientedUpImage {
            showActivityIndicator(showing: true)
            VisionStore.postScan(imageData: image.base64EncodedString, completionHandler: {[weak self] (response, error) in
                guard let strongSelf = self else { return }
                strongSelf.showActivityIndicator(showing: false)
                if let error = error {
                    strongSelf.showAlert(title: nil, message: error.localizedDescription)
                    return
                }
                
                guard let response = response else { return }
                let imageData =  UIImagePNGRepresentation(image)!
                let thumbnailImageData = UIImageJPEGRepresentation(image, 0.1)!
                let vision = Vision.insert(imageData: imageData, thumbnailImageData: thumbnailImageData,labelText: response.label, ocrText: response.ocr, faceText: response.face, moc: strongSelf.managedObjectContext)
                
                do {
                    try strongSelf.managedObjectContext.save()
                    strongSelf.performSegue(withIdentifier: detailSegue, sender: vision)
                } catch {
                    strongSelf.showAlert(title: nil, message: error.localizedDescription)
                }
            })
            
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()

    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? VisionTableViewCell {
                let vision = fetchedResultsController.object(at: indexPath)
                cell.setup(vision: vision)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }

    
}
