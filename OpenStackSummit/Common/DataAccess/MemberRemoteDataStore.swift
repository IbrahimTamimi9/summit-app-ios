//
//  MemberRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import AeroGearHttp
import AeroGearOAuth2

@objc
public protocol IMemberRemoteDataStore {
    func addEventToShedule(memberId: Int, eventId: Int, completionBlock : (NSError?) -> Void)
    func getById(memberId: Int, completionBlock : (Member?, NSError?) -> Void)
    func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)
}

public class MemberRemoteDataStore: NSObject {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    override init() {
        super.init()
    }
    
    init(deserializerFactory: DeserializerFactory ) {
        self.deserializerFactory = deserializerFactory
    }

    public func addEventToShedule(memberId: Int, eventId: Int, completionBlock : (NSError?) -> Void) {

        completionBlock(nil)
    }
    
    public func getById(memberId: Int, completionBlock : (Member?, NSError?) -> Void) {
        let json = "{\"id\":1,\"name\":\"Enzo\",\"lastName\":\"Francescoli\",\"email\":\"enzo@riverplate.com\",\"scheduledEvents\":[1],\"bookmarkedEvents\":[2]}"
        
        let member : Member
        var deserializer : IDeserializer!
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.Member)
        member = try! deserializer.deserialize(json) as! Member
        
        completionBlock(member, nil)
    }
    
    func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)  {
        let attendeeEndpoint = "https://dev-resource-server/api/v1/summits/current/attendees/me?expand=schedule,ticket_type,speaker"
        let http = httpFactory.create(HttpType.OpenID)
        http.GET(attendeeEndpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as? String {
                let deserializer = self.deserializerFactory.create(DeserializerFactoryType.Member)
                let member = try! deserializer.deserialize(json) as! Member
                completionBlock(member, error)
            }
        })
    }
}