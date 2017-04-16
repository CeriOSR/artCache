//
//  RootViewController.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-06.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class RootViewController: UIViewController {
    
    var values = [String: AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
    
    }
    
    func checkIfUserIsLoggedIn() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid == nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            let loginController = LoginController()
            present(loginController, animated: true, completion: nil)
        } else {
            enterUserToDatabase(values: values)
            let tabBarController = TabBarController()
            present(tabBarController, animated: true, completion: nil)
        }

    }
    
    func checkIfUserShouldBeEnteredIntoDB() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let dataRef = FIRDatabase.database().reference().child("users").child(uid)
        dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.fbId = dictionary["id"] as? String
                let tabBarController = TabBarController()
                self.present(tabBarController, animated: true, completion: nil)
            } else {
                self.enterUserToDatabase(values: self.values)
                let user = User()
                user.name = self.values["name"] as? String
                user.email = self.values["email"] as? String
                user.fbId = self.values["id"] as? String
                let tabBarController = TabBarController()
                self.present(tabBarController, animated: true, completion: nil)
            }
        }, withCancel: nil)
    }
    
    func enterUserToDatabase(values: [String: AnyObject]) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let userRef = FIRDatabase.database().reference().child("users").child(uid)
        userRef.updateChildValues(values)
        let user = User()
        user.name = self.values["name"] as? String
        user.email = self.values["email"] as? String
        user.fbId = self.values["id"] as? String
        let tabBarController = TabBarController()
        self.present(tabBarController, animated: true, completion: nil)

    }

}
