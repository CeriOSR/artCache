//
//  TabBarController.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-05.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class TabBarController: UITabBarController {
    
    let routesAndDecisions = RoutesAndDecisions()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let routesAndDecisions = RoutesAndDecisions()
        viewControllers = routesAndDecisions.checkIfUserExistAndWhoIsUser()
    }
}

        
        
//        let uid = FIRAuth.auth()?.currentUser?.uid
        
//        let layoutTracker = UICollectionViewFlowLayout()
//        let artTrackerCollectionViewController = ArtTrackerCollectionViewController(collectionViewLayout: layoutTracker)
//        let artTrackerNavController = UINavigationController(rootViewController: artTrackerCollectionViewController)
//        artTrackerNavController.tabBarItem.title = "Tracker"
//        artTrackerNavController.tabBarItem.image = UIImage(named: "people")
//        
//        let addArtController = AddArtController()
//        let addArtNavController = UINavigationController(rootViewController: addArtController)
//        addArtNavController.tabBarItem.title = "Add Art"
//        addArtNavController.tabBarItem.image = UIImage(named: "groups")
//        
//        let layoutPending = UICollectionViewFlowLayout()
//        let pendingArtsCollectionViewController = PendingArtsCollectionViewController(collectionViewLayout: layoutPending)
//        let pendingNavController = UINavigationController(rootViewController: pendingArtsCollectionViewController)
//        pendingNavController.tabBarItem.title = "Pending Art"
//        pendingNavController.tabBarItem.image = UIImage(named: "people")
        
    
//        if uid == nil {
//            let loginManager = FBSDKLoginManager()
//            loginManager.logOut()
//            let loginController = LoginController()
//            present(loginController, animated: true, completion: nil)
//        } else if uid == "oDqT2PMCxeWFLzo8LnWxHlgMB4Y2" {
//            viewControllers = [artTrackerNavController, addArtNavController, pendingNavController]
//        } else {
//            viewControllers = [artTrackerNavController, addArtNavController]
//        }
    
