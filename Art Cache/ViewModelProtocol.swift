//
//  RootViewModelProtocol.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-06-30.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import Foundation
import UIKit

protocol RootViewModelProtocol {
    var values: [String: AnyObject] {get set}
    
    func checkIfUserIsLoggedIn() -> UIViewController
    func checkIfUserShouldBeEnteredIntoDB()
    func enterUserToDatabase(values: [String: AnyObject])

}

protocol LoginViewModelProtocol {
    
    var values: [String: AnyObject] {get set}
    
    func loginUserToFirebase(_ completion: () -> Void)
    func fbGraphRequest()
}

protocol TabControllerProtocol {
    func checkUserCredentials()
}

