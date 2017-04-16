//
//  ArtCommentCollectionViewController.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-14.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class ArtCommetCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var containerViewVerticalConstraint: NSLayoutConstraint?

    var art = Art() {
        didSet{
            navigationItem.title = art.title
        }
    }
    
    var comments = [Comments]()
    var user = User()
    
    let textField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "enter comment"
    return textField
    }()
    
    lazy var sendButton: UIButton = {
    let sendButton = UIButton(type: .system)
    sendButton.setTitle("Send", for: .normal)
    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    return sendButton
    }()

    
//    let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchUserInfo()
//        setupViews()
//        setupKeyboardObservers()
    }
    
    //remove notifications or else mem leak
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchComments()
    }
    
    lazy var inputContainerView: UIView = {
        
        
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        containerView.addSubview(self.textField)
        containerView.addSubview(self.sendButton)
        containerView.addConstraintsWithFormat(format: "H:|-2-[v0]-2-[v1(65)]|", views: self.textField, self.sendButton)
        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: self.textField)
        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: self.sendButton)
        
        return containerView

    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        let comment = comments[indexPath.item]
        cell.textView.text = comment.comment
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    func setupCollectionView() {
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .blue
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
    }
    
    func fetchUserInfo() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let userRef = FIRDatabase.database().reference().child("users").child(uid)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            self.user.email = dictionary?["email"] as? String
            self.user.fbId = dictionary?["fbId"] as? String
            self.user.name = dictionary?["name"] as? String
        }, withCancel: nil)
        
    }
    
    func handleSend() {
        guard let comment = textField.text else {return}
        guard let artId = art.artId else {return}
        if textField.text == "" {
            return
        } else {
            guard let values = ["posterName": user.name, "date": String(describing: Date()), "comment": comment ] as? [String: String] else {return}
            let commentsRef = FIRDatabase.database().reference().child("comment").childByAutoId()
            commentsRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
                if error != nil {
                    print("Something went wrong", error ?? "unknown error")
                    return
                }
                let commentId = commentsRef.key
                let panRef = FIRDatabase.database().reference().child("comments_fanning").child(artId)
                panRef.updateChildValues([commentId: 1])
                DispatchQueue.main.async(execute: { 
                    self.collectionView?.reloadData()
                })
                self.textField.text = ""
            })
        }
    }
    
    func fetchComments() {
        guard let artId = art.artId else {return}
        comments = []
        let panRef = FIRDatabase.database().reference().child("comments_fanning").child(artId)
        panRef.observe(.childAdded, with: { (snapshot) in
            let commentId = snapshot.key
            let commentRef = FIRDatabase.database().reference().child("comment").child(commentId)
            commentRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? [String: AnyObject]
                let comment = Comments()
                comment.comment = dictionary?["comment"] as? String
                comment.date = dictionary?["date"] as? String
                comment.posterName = dictionary?["posterName"] as? String
                
                self.comments.append(comment)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
            }, withCancel: nil)
        }, withCancel: nil)
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

//    func setupViews() {
//        view.addSubview(containerView)
//        
//        //x, y, w, h
//        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        containerViewVerticalConstraint =  containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        containerViewVerticalConstraint?.isActive = true
//        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        
//        containerView.addSubview(textField)
//        containerView.addSubview(sendButton)
//        
//        containerView.addConstraintsWithFormat(format: "H:|-2-[v0]-2-[v1(65)]|", views: textField, sendButton)
//        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: textField)
//        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
//    }
    
//    func setupKeyboardObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        
//    }
//    
//    //animating the containerView to go above the keyboard
//    func handleKeyboardWillHide(notification: Notification) {
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//        containerViewVerticalConstraint?.constant = 0
//        UIView.animate(withDuration: keyboardDuration!) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    func handleKeyboardWillShow(notification: Notification) {
//        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//        containerViewVerticalConstraint?.constant = -(keyboardFrame?.height)!
//        UIView.animate(withDuration: keyboardDuration!) { 
//            self.view.layoutIfNeeded()
//        }
//    }
    
}

