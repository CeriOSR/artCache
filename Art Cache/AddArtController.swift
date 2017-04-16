//
//  AddArtController.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-05.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class AddArtController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    var locationManager = CLLocationManager()
    var latitude = String()
    var longitude = String()
    var values = [String: String]()
    
    lazy var titleTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Enter title"
        tf.delegate = self
        return tf
    }()
    
    lazy var artistTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Enter artist name"
        tf.delegate = self
        return tf
    }()

    
    lazy var descriptionTextview: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.delegate = self
        return textView
    }()
    
    lazy var hintTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.delegate = self
        return textView
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImage)))
        image.image = #imageLiteral(resourceName: "taka")
        return image
    }()
    
    let placeholderLabel = UILabel()
    let placeholderDescriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd))
        setupViews()
        generatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        generatingLocation()
    }
    
    func setupViews() {
        
        view.backgroundColor = .white
        
        placeholderLabel.text = "Enter hints..."
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (hintTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        hintTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (hintTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !hintTextView.text.isEmpty
        
        placeholderDescriptionLabel.text = "Enter description..."
        placeholderDescriptionLabel.font = UIFont.italicSystemFont(ofSize: (descriptionTextview.font?.pointSize)!)
        placeholderDescriptionLabel.sizeToFit()
        descriptionTextview.addSubview(placeholderDescriptionLabel)
        placeholderDescriptionLabel.frame.origin = CGPoint(x: 5, y: (descriptionTextview.font?.pointSize)! / 2)
        placeholderDescriptionLabel.textColor = UIColor.lightGray
        placeholderDescriptionLabel.isHidden = !descriptionTextview.text.isEmpty
        
        view.addSubview(titleTextField)
        view.addSubview(artistTextField)
        view.addSubview(descriptionTextview)
        view.addSubview(hintTextView)
        view.addSubview(imageView)
        
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: titleTextField)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: artistTextField)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: descriptionTextview)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: hintTextView)
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: imageView)

        view.addConstraintsWithFormat(format: "V:|-75-[v0(26)]-10-[v1(26)]-10-[v2(60)]-10-[v3(40)]-10-[v4(200)]", views: titleTextField, artistTextField, descriptionTextview, hintTextView, imageView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !hintTextView.text.isEmpty
        placeholderDescriptionLabel.isHidden = !descriptionTextview.text.isEmpty
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //maybe do something later but i dont wanna type return
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    
    func handleAdd() {
        saveImageToFIRStorage()
    }
    
    func saveImageToFIRStorage() {
        let artName = NSUUID().uuidString
        guard let image = imageView.image, let uploadData = UIImageJPEGRepresentation(image, 0.3) else {return}
        let storageRef = FIRStorage.storage().reference().child("art_images").child(artName)
        storageRef.put(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error ?? "unknown error...")
                return
            }
            let imageUrl = metadata?.downloadURL()?.absoluteString
            self.valuesToBeEnteredToDb(imageUrl: imageUrl)
        }
    }
    
    func valuesToBeEnteredToDb(imageUrl: String?) {
        guard let title = titleTextField.text else {return}
        guard let artist = artistTextField.text else {return}
        guard let desc = descriptionTextview.text else {return}
        guard let hint = hintTextView.text else {return}
        guard let imageUrl = imageUrl else {return}
        let date = String(describing:Date())
        guard let posterId = FIRAuth.auth()?.currentUser?.uid else {return}
        values = ["title": title, "artist": artist, "desc": desc, "hint": hint, "imageUrl": imageUrl, "date": date, "latitude": latitude, "longitude": longitude, "posterId": posterId]
        saveArtToDatabase(values: values)
    }
    
    func saveArtToDatabase(values: [String: String]) {
        let databaseRef = FIRDatabase.database().reference().child("art").childByAutoId()
        databaseRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                self.createAlert(title: "Could Not Save!", message: "Try again.")
                return
            }
            let panRefId = databaseRef.key
            let panRef = FIRDatabase.database().reference().child("pending_art")
            panRef.updateChildValues([panRefId:1])
            self.createAlert(title: "Pending Approval!", message: "Waiting for approval from admin.")
            self.titleTextField.text = ""
            self.artistTextField.text = ""
            self.descriptionTextview.text = ""
            self.hintTextView.text = ""
            self.imageView.image = #imageLiteral(resourceName: "taka")
        }
    }
    
    //image picker
    func handleSelectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker = UIImage()
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker as UIImage? {
            imageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //location manager
    func generatingLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else {return}
        latitude = String(describing: location.latitude)
        longitude = String(describing: location.longitude)
    }

    //controlling the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //needs UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
}
