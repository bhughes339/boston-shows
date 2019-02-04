//
//  SingleEvent.swift
//  boston-shows
//
//  Created by William Hughes on 3/29/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import Foundation

class SingleEvent: Hashable {
    
    var hashValue: Int {
        return startTime.hashValue ^ venue.hashValue &* 16777619
    }
    
    static func == (lhs: SingleEvent, rhs: SingleEvent) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    let startTime: Date
    let venue: String
    let bands: [String]
    let link: String?
    let soldout: Bool?
    
    init(startTime: Date, venue: String, bands: [String], link: String? = nil, soldout: Bool? = false) {
        self.startTime = startTime
        self.venue = venue
        self.bands = bands
        self.link = link
        self.soldout = soldout
    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(id, forKey: "id")
//        aCoder.encode(startTime, forKey: "startTime")
//        aCoder.encode(venue, forKey: "venue")
//        aCoder.encode(bands, forKey: "bands")
//        aCoder.encode(link, forKey: "link")
//    }
//
//    required convenience init?(coder aDecoder: NSCoder) {
//        let id = aDecoder.decodeObject(forKey: "id") as! String
//        let startTime = aDecoder.decodeObject(forKey: "startTime") as! Date
//        let venue = aDecoder.decodeObject(forKey: "venue") as! String
//        let bands = aDecoder.decodeObject(forKey: "bands") as! [String]
//        let link = aDecoder.decodeObject(forKey: "link") as? String
//        self.init(id: id, startTime: startTime, venue: venue, bands: bands, link: link)
//    }
}
