//
//  ArtTrackerCollectionViewController.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-05.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FBSDKLoginKit
import CoreLocation

private let reuseIdentifier = "Cell"

class ArtTrackerCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var userCoordinates = CLLocationCoordinate2D()
    var locations = [Location]()
    var arts = [Art]()
    
    var artLocations = [CLLocationCoordinate2D]()  //append the various art coordinates to this by self.artLocation(CLLocationCoordinate2D(latitude: ,longitude: ) during the fetchArt()
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    //pull to refresh (new thing i just freaking learned!)
    lazy var updateData: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Updating the data")
        refresh.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        collectionView?.backgroundColor = .white
        collectionView?.isScrollEnabled = true
        collectionView?.alwaysBounceVertical = true
        self.collectionView!.register(ArtTrackerCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //setupViews()
        scrollToBottom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchApprovedArt()
        scrollToBottom()
        generatingLocation()
        
    }
    
    //scroll to bottom
    func scrollToBottom() {
        if arts.count > 0 {
            let indexPath = NSIndexPath(item: arts.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    //always call this and for notifications because it will cause a mem leak otherwise
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ArtTrackerCollectionViewCell
        
        let art = arts[indexPath.item]
        if let imageUrl = art.imageUrl {
            cell.imageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
        }
        cell.titleLabel.text = art.title
        distanceBetweenUserAndArt(cell: cell, indexPath: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let artDetailController = ArtDetailController()
        artDetailController.art = arts[indexPath.item]
        artDetailController.artLocation = locations[indexPath.item]
        let artDetailNavController = UINavigationController(rootViewController: artDetailController)
        self.present(artDetailNavController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60.0)
    }
    
    func setupViews() {
        view.addSubview(mapView)
        collectionView?.addSubview(updateData)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: mapView)
        view.addConstraintsWithFormat(format: "V:[v0(275)]|", views: mapView)
    }
    
    func generatingLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let annotationUser = MKPointAnnotation()
        guard let location = manager.location?.coordinate else {return}
        userLocation = location
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: center, span: span)
        self.mapView.setRegion(region, animated: true)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        annotationUser.coordinate = center
        annotationUser.title = "Your Location"
        self.mapView.addAnnotation(annotationUser)
        
        addArtAnnotation()
    }
    
    func fetchApprovedArt() {
        self.arts = []
        self.locations = []
        let panRef = FIRDatabase.database().reference().child("approved_art")
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
                
                art.artist = dictionary?["artist"] as? String
                art.desc = dictionary?["desc"] as? String
                art.hint = dictionary?["hint"] as? String
                art.posterId = dictionary?["posterId"] as? String
                art.title = dictionary?["title"] as? String
                art.imageUrl = dictionary?["imageUrl"] as? String
                art.artId = snapshot.key
                
                self.locations.append(location)
                self.arts.append(art)
                
                DispatchQueue.main.async(execute: { 
                    self.collectionView?.reloadData()
                })
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func addArtAnnotation() {
        for location in locations {
            for art in arts {
                let annotation = MKPointAnnotation()
                guard let latitude = location.latitude, let longitude = location.longitude else {return}
                annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude)!, longitude: CLLocationDegrees(longitude)!)
                annotation.title = art.title
                annotation.subtitle = art.hint
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func reloadData() {
        fetchApprovedArt()
        stopReload()
    }
    
    func stopReload() {
        self.updateData.endRefreshing()
    }
    
    func distanceBetweenUserAndArt(cell: BaseCell, indexPath: IndexPath) {
        if let latitude = Double(locations[indexPath.item].latitude!), let longitude = Double(locations[indexPath.item].longitude!) {
            
            let artLocation = CLLocationCoordinate2DMake(latitude, longitude)
            let artCoordinates = MKMapPointForCoordinate(artLocation)
            let userCoordinates = MKMapPointForCoordinate(userLocation)
            let distance = MKMetersBetweenMapPoints(userCoordinates, artCoordinates)
            
            if distance <= 50000 {
                cell.backgroundColor = .green
            } else {
                cell.backgroundColor = .white
            }
            
        }
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch { return }
        checkIfUserLoggedIn()
    }
    
    func checkIfUserLoggedIn() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid == nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            let loginController = LoginController()
            present(loginController, animated: true, completion: nil)
        } else {
            //do nothing
        }
    }
}
