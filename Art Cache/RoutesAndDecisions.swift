//
//  TabBarViewModel.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-07-04.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKLoginKit

class RoutesAndDecisions: NSObject, RoutesAndDecisionsProtocol {
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    func checkIfUserExistAndWhoIsUser() -> [UINavigationController]{
        
        let layoutTracker = UICollectionViewFlowLayout()
        let artTrackerCollectionViewController = ArtTrackerCollectionViewController(collectionViewLayout: layoutTracker)
        let artTrackerNavController = UINavigationController(rootViewController: artTrackerCollectionViewController)
        artTrackerNavController.tabBarItem.title = "Tracker"
        artTrackerNavController.tabBarItem.image = UIImage(named: "people")
        
        let addArtController = AddArtController()
        let addArtNavController = UINavigationController(rootViewController: addArtController)
        addArtNavController.tabBarItem.title = "Add Art"
        addArtNavController.tabBarItem.image = UIImage(named: "groups")
        
        let layoutPending = UICollectionViewFlowLayout()
        let pendingArtsCollectionViewController = PendingArtsCollectionViewController(collectionViewLayout: layoutPending)
        let pendingNavController = UINavigationController(rootViewController: pendingArtsCollectionViewController)
        pendingNavController.tabBarItem.title = "Pending Art"
        pendingNavController.tabBarItem.image = UIImage(named: "people")

        var navControllers = [UINavigationController]()
        
        if uid == "" {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            let loginController = LoginController()
            self.topViewController()?.present(loginController, animated: true, completion: nil)
        } else if uid == "oDqT2PMCxeWFLzo8LnWxHlgMB4Y2" {
            navControllers = [artTrackerNavController, addArtNavController, pendingNavController]
        } else {
            navControllers = [artTrackerNavController, addArtNavController]
        }
        
        return navControllers
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
