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
    var art2DCoordinates = CLLocationCoordinate2D()
    var user2DCoordinates = CLLocationCoordinate2D()

    let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blur = UIVisualEffectView(effect: blurEffect)
        return blur
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var commentImageView: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "comment")
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushCommentController)))
        return image
    }()
    
    lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.isUserInteractionEnabled = true
        label.text = "comment"
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushCommentController)))
        return label
    }()
    
    lazy var likeImageView: UIImageView = {
       let image = UIImageView()
        image.image = #imageLiteral(resourceName: "like")
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    let separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Claim", style: .plain, target: self, action: #selector(handleClaimArt))
        view.backgroundColor = .white
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
        view.addSubview(blurView)
        view.addSubview(separatorLineView)
        blurView.addSubview(artistLabel)
        blurView.addSubview(descriptionLabel)
        blurView.addSubview(commentImageView)
        blurView.addSubview(commentLabel)
        
        view.addSubview(mapView)
        
        view.addConstraintsWithFormat(format: "H:|-50-[v0]-50-|", views: imageView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: mapView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: separatorLineView)
        view.addConstraintsWithFormat(format: "V:|-50-[v0][v1(74)][v2(2)][v3(275)]|", views: imageView, blurView, separatorLineView, mapView)
        
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: blurView)
        //view.addConstraintsWithFormat(format: "V:[v0(76)]|", views: blurView)
        
        blurView.addConstraintsWithFormat(format: "H:|-2-[v0]-2-|", views: artistLabel)
        blurView.addConstraintsWithFormat(format: "H:|-2-[v0]-2-|", views: descriptionLabel)
        
        blurView.addConstraintsWithFormat(format: "V:|[v0(16)]-2-[v1(36)]", views: artistLabel, descriptionLabel)
        
        blurView.addConstraintsWithFormat(format: "H:|-4-[v0(20)]-2-[v1(60)]", views: commentImageView, commentLabel)
        blurView.addConstraintsWithFormat(format: "V:[v0(20)]-4-|", views: commentImageView)
        blurView.addConstraintsWithFormat(format: "V:[v0(20)]-4-|", views: commentLabel)
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
        guard let artLatitude = Double((art?.latitude)!) else {return}
        guard let artLongitude = Double((art?.longitude)!) else {return}
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
        
        self.mapView.addAnnotation(artAnnotation)
        self.mapView.addAnnotation(userAnnotation)
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
