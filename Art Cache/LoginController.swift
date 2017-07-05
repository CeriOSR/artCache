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
    
    let loginViewModel = LoginViewModel()
    
    let artCacheImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "art_Cache")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let alternativeLogoImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "retry")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let posabilitiesLogoImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "rey_posA_logo")
        image.contentMode = .scaleAspectFit
        return image
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupViews()
    }
    
    func setupViews() {
        
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        loginButton.frame = CGRect(x: 16, y: 400, width: self.view.frame.width - 32, height: 50)
        
        view.addSubview(loginButton)
        view.addSubview(artCacheImage)
        view.addSubview(alternativeLogoImage)
        view.addSubview(posabilitiesLogoImage)
                
        view.addConstraintsWithFormat(format: "H:|-6-[v0]-6-|", views: artCacheImage)
        view.addConstraintsWithFormat(format: "V:|-100-[v0(150)]", views: artCacheImage)
        
        view.addConstraintsWithFormat(format: "H:|-6-[v0]-6-|", views: alternativeLogoImage)
        view.addConstraintsWithFormat(format: "V:[v0(100)]-90-|", views: alternativeLogoImage)
        
        view.addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: posabilitiesLogoImage)
        view.addConstraintsWithFormat(format: "V:[v0(14)]-60-|", views: posabilitiesLogoImage)
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            loginButton.shake()
            return
        }
        print("successfully logged in with facebook!")
        loginViewModel.loginUserToFirebase { 
            let rootViewController = RootViewController()
            self.present(rootViewController, animated: true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did Logout of facebook!")
    }
}
