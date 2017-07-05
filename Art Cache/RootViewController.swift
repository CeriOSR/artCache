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
    
    let rootViewModel = RootViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        present(self.rootViewModel.checkIfUserIsLoggedIn(), animated: true, completion: nil)
    }    
}
