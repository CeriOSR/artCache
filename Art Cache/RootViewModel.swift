//
//  RootViewModel.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-07-01.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKLoginKit

class RootViewModel: NSObject, RootViewModelProtocol  {
    
    var values = [String: AnyObject]()
    
    func checkIfUserIsLoggedIn() -> UIViewController {
        let uid = FIRAuth.auth()?.currentUser?.uid
        var presentableController = UIViewController()
        if uid == nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            presentableController = LoginController()
        } else {
            enterUserToDatabase(values: values)
            presentableController = TabBarController()
        }
        return presentableController
        
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
            } else {
                self.enterUserToDatabase(values: self.values)
                let user = User()
                user.name = self.values["name"] as? String
                user.email = self.values["email"] as? String
                user.fbId = self.values["id"] as? String
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
    }
}

