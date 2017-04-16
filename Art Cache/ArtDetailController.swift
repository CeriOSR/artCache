//
//  ArtDetailController.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-05.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class ArtDetailController: UIViewController, CLLocationManagerDelegate {
    
    var art: Art? {
        didSet{
            navigationItem.title = art?.title
            if let imageUrl = art?.imageUrl {
                imageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
            }
            artistLabel.text = art?.artist
            descriptionLabel.text = art?.desc
        }
    }
    let locationManager = CLLocationManager()
    var artLocation = Location()
    var art2DCoordinates = CLLocationCoordinate2D()
    var user2DCoordinates = CLLocationCoordinate2D()

    let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushCommentController)))
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center

        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Claim", style: .plain, target: self, action: #selector(handleClaimArt))
        generatingLocations()
        setupViews()
    }
    
    //if you dont stop it, will cause a mem leak...do this for all notifications too
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //maybe do something later but i dont wanna type return
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupViews() {
        view.addSubview(imageView)
        view.addSubview(artistLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(mapView)
        
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: mapView)
        view.addConstraintsWithFormat(format: "V:|[v0][v1(275)]|", views: imageView, mapView)
        
        view.addConstraintsWithFormat(format: "H:|-2-[v0]-2-|", views: artistLabel)
        view.addConstraintsWithFormat(format: "H:|-2-[v0]-2-|", views: descriptionLabel)
        
        view.addConstraintsWithFormat(format: "V:|-200-[v0(26)]-10-[v1(78)]", views: artistLabel, descriptionLabel)
    }
    
    func handleBack() {
        let tabBarController = TabBarController()
        present(tabBarController, animated: true, completion: nil)
    }
    
    func generatingLocations() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userAnnotation = MKPointAnnotation()
        let artAnnotation = MKPointAnnotation()
        guard let artLatitude = Double((artLocation.latitude)!) else {return}
        guard let artLongitude = Double((artLocation.longitude)!) else {return}
        let center = CLLocationCoordinate2DMake(artLatitude, artLongitude)
        art2DCoordinates = center
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: center, span: span)
        self.mapView.setRegion(region, animated: true)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        artAnnotation.coordinate = center
        artAnnotation.title = art?.title
        guard let userLocation = manager.location?.coordinate else {return}
        user2DCoordinates = userLocation
        userAnnotation.coordinate = userLocation
        userAnnotation.title = "Your location"
        self.mapView.addAnnotation(userAnnotation)
        self.mapView.addAnnotation(artAnnotation)
        
    }
    
    func pushCommentController() {
        let layout = UICollectionViewFlowLayout()
        let artCommentCollectionViewController = ArtCommetCollectionViewController(collectionViewLayout: layout)
        guard let specificArt = art else {return}
        artCommentCollectionViewController.art = specificArt
        navigationController?.pushViewController(artCommentCollectionViewController, animated: true)
    }
    
    func handleClaimArt() {
        
        let artCoordinates = MKMapPointForCoordinate(art2DCoordinates)
        let userCoordinates = MKMapPointForCoordinate(user2DCoordinates)
        let distance = MKMetersBetweenMapPoints(artCoordinates, userCoordinates)
        
        if distance <= 2 {
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
            print(art?.artId ?? "")
            guard let artId = art?.artId else {return}
            let claimedRef = FIRDatabase.database().reference().child("claimed")
            claimedRef.updateChildValues([uid: artId])
            let approvedRef = FIRDatabase.database().reference().child("approved_art").child(artId)
            approvedRef.removeValue { (error, ref) in
                if error != nil {
                    print(error ?? "unknown error")
                }
                self.createAlert(title: "Congratulations!!!", message: "You have claimed this art.")
            }
        } else {
            self.createAlert(title: "Need To Be Closer To Claim", message: "You have to be within 2 meter from the art to claim")
        }
    }
}
