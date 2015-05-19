//
//  Tweet.swift
//  TweetsVisualizer
//
//  Created by Linyin Wu on 8/5/15.
//  Copyright (c) 2015 Linyin Wu. All rights reserved.
//

import Foundation
import CoreLocation
import TwitterKit
class Tweet {
    var name : String
    var text : String
    var coordinate : CLLocationCoordinate2D?
    var id : String
    var timestamp : NSString
    var avatarUrl : NSString
    var polarity : NSNumber?
    
    init(id: String, name : String, text: String, timestamp: String, avatarUrl: NSString) {
        self.id = id
        self.name = name
        self.text = text
        self.timestamp = timestamp
        self.avatarUrl = avatarUrl
    }
}