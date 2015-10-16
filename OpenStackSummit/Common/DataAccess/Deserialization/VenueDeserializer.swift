//
//  VenueDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class VenueDeserializer: NSObject, IDeserializer {

    var deserializerStorage: DeserializerStorage!
    var deserializerFactory: DeserializerFactory!
    
    public init(deserializerStorage: DeserializerStorage, deserializerFactory: DeserializerFactory) {
        self.deserializerStorage = deserializerStorage
        self.deserializerFactory = deserializerFactory
    }
    
    public override init() {
        super.init()
    }
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        let venue : Venue
        
        if let venueId = json.int {
            venue = deserializerStorage.get(venueId)
        }
        else {
            var deserializer = deserializerFactory.create(DeserializerFactoryType.Location)
            let location = try deserializer.deserialize(json) as! Location
            venue = Venue()
            venue.id = json["id"].intValue
            venue.name = location.name
            venue.locationDescription = location.locationDescription
            venue.lat = json["lat"].stringValue
            venue.long = json["lng"].stringValue
            venue.address = json["address_1"].stringValue
            venue.city = json["city"].stringValue
            venue.state = json["state"].stringValue
            venue.zipCode = json["zip_code"].stringValue
            venue.country = json["country"].stringValue
            venue.isInternal = json["location_type"].stringValue == "Internal"
            
            var map: Image
            deserializer = deserializerFactory.create(DeserializerFactoryType.Image)
            for (_, mapJSON) in json["maps"] {
                map = try deserializer.deserialize(mapJSON) as! Image
                venue.maps.append(map)
            }
                        
            deserializerStorage.add(venue)
        }
        
        return venue
    }
}
