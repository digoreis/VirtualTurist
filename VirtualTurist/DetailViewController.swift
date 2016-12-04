//
//  DetailViewController.swift
//  VirtualTurist
//
//  Created by apple on 04/12/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UICollectionViewDataSource {
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var observerContext = 0
    
    var pin : Pin?
    override func viewDidAppear(_ animated: Bool) {
        if (pin?.load ?? false) {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
        
        pin?.addObserver(self, forKeyPath: "photos", options: NSKeyValueObservingOptions.new, context: &observerContext)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin?.photos?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PhotoCollectionViewCell ?? PhotoCollectionViewCell()
        if let photo = pin?.photos?.allObjects[indexPath.row] as? Photo, let data = photo.data {
            cell.image.image = UIImage(data: data)
        }
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    
    @IBAction func deletePin(_ sender: Any) {
        if let app = UIApplication.shared.delegate as? AppDelegate, let pin = pin {
            app.stack.context.delete(pin)
            self.close(self)
        }
    }
    
    

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if (self.pin?.load ?? false) {
                self.deleteButton.isHidden = false
            } else {
                self.deleteButton.isHidden = true
            }
        }
    }

}
