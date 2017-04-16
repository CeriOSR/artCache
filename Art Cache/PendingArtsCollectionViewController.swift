//
//  PendingArtsCollectionViewController.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-07.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class PendingArtsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var art: Art?
    var arts = [Art]()
    var locations = [Location]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        self.collectionView!.register(PendingCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //fetchPendingArts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchPendingArts()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PendingCell
//        cell.art = arts[indexPath.item]
        art = arts[indexPath.item]
        if let imageUrl = art?.imageUrl {
            cell.imageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
        }
        cell.titleLabel.text = art?.title
        cell.acceptButton.addTarget(self, action: #selector(handleAccept(_:)), for: .touchUpInside)

    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func handleLogout() {
        
    }
    
    func goToArtTrackerController() {
        
    }
    
    func fetchPendingArts() {
        self.arts = []
        self.locations = []
        let panRef = FIRDatabase.database().reference().child("pending_art")
        panRef.observe(.childAdded, with: { (snapshot) in
            let panId = snapshot.key
            let databaseRef = FIRDatabase.database().reference().child("art").child(panId)
            databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dictionary = snapshot.value as? [String: AnyObject]
                let art = Art()
                let location = Location()
                location.date = dictionary?["date"] as? String
                location.latitude = dictionary?["latitude"] as? String
                location.longitude = dictionary?["longitude"] as? String
                self.locations.append(location)
                
                art.artId = snapshot.key as String
                art.artist = dictionary?["artist"] as? String
                art.desc = dictionary?["desc"] as? String
                art.hint = dictionary?["hint"] as? String
                art.posterId = dictionary?["posterId"] as? String
                art.title = dictionary?["title"] as? String
                art.imageUrl = dictionary?["imageUrl"] as? String
                
                self.arts.append(art)
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func handleAccept(_ sender: UIButton) {
        print("button pressed")
        let cell = sender.superview
        guard let indexPath = collectionView?.indexPath(for: cell as! UICollectionViewCell) else {return}
        //guard let artId = art?.artId else {return}
        guard let artId = arts[indexPath.item].artId else {return}
        let approvedRef = FIRDatabase.database().reference().child("approved_art")
        approvedRef.updateChildValues([artId: 1])
        let pendingRef = FIRDatabase.database().reference().child("pending_art").child("\(artId)")
        pendingRef.removeValue { (error, ref) in
            if error != nil {
                return
            }
//            let layout = UICollectionViewFlowLayout()
//            let pendingArtCollectionViewController = PendingArtsCollectionViewController(collectionViewLayout: layout)
            self.arts.remove(at: indexPath.item)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
}
