//
//  Model.swift
//  NaverAPIExample
//
//  Created by MBP04 on 2018. 4. 5..
//  Copyright © 2018년 codershigh. All rights reserved.
//

import Foundation
import UIKit

class Movie {
    var title:String
    var link:String
    var imageURL:String
    var image:UIImage?
    var pubDate:Int
    var director:String
    var actors:String
    var userRating:Double
    
    init (title:String, link:String, imageURL:String, pubDate:Int, director:String, actors:String, userRating:Double) {
        self.title = title
        self.link = link
        self.imageURL = imageURL
        self.pubDate = pubDate
        self.director = director
        self.actors = actors
        self.userRating = userRating
    }
}
