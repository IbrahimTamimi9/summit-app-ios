//
//  LocationDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class SummitLocationDeserializer: DeserializerProtocol {
    
    public func deserialize(json: JSON) -> BaseEntity {
        let summitLocation = SummitLocation()
        
        summitLocation.id = json["id"].intValue
        summitLocation.locationDescription = json["description"].stringValue
        
        return summitLocation
    }
}
