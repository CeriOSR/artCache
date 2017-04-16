//
//  LoginController.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-06.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    
    var values = [String: AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    func setupViews() {
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 16, y: 150, width: view.frame.width - 32, height: 50)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("successfully logged in with facebook!")
        loginUserToFirebase()
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did Logout of facebook!")
    }
    
    
    func loginUserToFirebase() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {return}
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print(error ?? "Something went wrong")
                return
            }
            print("current", self.values)
            self.fbGraphRequest()
        })
    }
    
    func fbGraphRequest() {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print(error ?? "error unknown")
                return
            }
            print(result ?? "no result")
            self.values = result as! [String: AnyObject]
            print(self.values)
            let rootViewController = RootViewController()
            rootViewController.values = self.values
            self.present(rootViewController, animated: true, completion: nil)
        }
    }
}
