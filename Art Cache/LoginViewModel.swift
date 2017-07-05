//
//  LoginViewModel.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-07-02.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import Firebase

class LoginViewModel: NSObject, LoginViewModelProtocol {
    
        var values = [String: AnyObject]()
    
    func loginUserToFirebase(_ completion: () -> Void) {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {fatalError()}
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print(error ?? "Something went wrong")
                return
            }
            self.fbGraphRequest()
        })
    }
    
    internal func fbGraphRequest(){
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print(error ?? "error unknown")
                return
            } else {
                print(result ?? "no result")
                self.values = result as! [String: AnyObject]
                print(self.values)
                weak var rootViewModel = RootViewModel()
                rootViewModel?.values = self.values
                let rootViewController = RootViewController()
                self.topViewController()?.present(rootViewController, animated: true,
                                             completion: nil)
            }
        }
    }
    
    func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
            if let tab = base as? UITabBarController {
                let moreNavigationController = tab.moreNavigationController                
                if let top = moreNavigationController.topViewController, top.view.window != nil {
                    return topViewController(top)
                } else if let selected = tab.selectedViewController {
                    return topViewController(selected)
                }
            }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
