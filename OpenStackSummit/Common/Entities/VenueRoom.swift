//
//  VenueRoom.swift
//  
//
//  Created by Claudio on 8/12/15.
//
//

import Foundation
import RealmSwift

public class VenueRoom: Location {

    public dynamic var capacity = 0
    var venue: Venue {
        return linkingObjects(Venue.self, forProperty: "venueRooms").first!
    }
    
}
