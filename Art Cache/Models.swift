//
//  Models.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-06.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String?
    var name: String?
    var fbId: String?
}

//class Location: NSObject {
//    var date: String?
//    var latitude: String?
//    var longitude: String?
//}

class Comments: NSObject {
    var comment: String?
    var date: String?
    var posterName: String?
}

class Art: NSObject {
    var artId: String?
    var title: String?
    var artist: String?
    var desc: String?
    var hint: String?
    var imageUrl: String?
    var posterId: String?
    var date: String?
    var latitude: String?
    var longitude: String?

}
