//
//  DataStoreAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon
import RealmSwift

public class DataStoreAssembly: TyphoonAssembly {
    public dynamic func deserializerFactory() -> AnyObject {
        return TyphoonDefinition.withClass(DeserializerFactory.self) {
            (definition) in
            
            definition.injectProperty("summitDeserializer", with: self.summitDeserializer())
            definition.injectProperty("companyDeserializer", with: self.companyDeserializer())
            definition.injectProperty("eventTypeDeserializer", with: self.eventTypeDeserializer())
            definition.injectProperty("summitTypeDeserializer", with: self.summitTypeDeserializer())
            definition.injectProperty("locationDeserializer", with: self.locationDeserializer())
            definition.injectProperty("venueDeserializer", with: self.venueDeserializer())
            definition.injectProperty("venueRoomDeserializer", with: self.venueRoomDeserializer())
            definition.injectProperty("summitEventDeserializer", with: self.summitEventDeserializer())
            definition.injectProperty("presentationDeserializer", with: self.presentationDeserializer())
            definition.injectProperty("trackDeserializer", with: self.trackDeserializer())
            definition.injectProperty("memberDeserializer", with: self.memberDeserializer())
            definition.injectProperty("presentationSpeakerDeserializer", with: self.presentationSpeakerDeserializer())
            definition.injectProperty("tagDeserializer", with: self.tagDeserializer())
            definition.injectProperty("imageDeserializer", with: self.imageDeserializer())
            definition.injectProperty("ticketTypeDeserializer", with: self.ticketTypeDeserializer())
            definition.injectProperty("summitAttendeeDeserializer", with: self.summitAttendeeDeserializer())
            definition.injectProperty("dataUpdateDeserializer", with: self.dataUpdateDeserializer())
        }
    }

    public dynamic func dataUpdateDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(DataUpdateDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func summitAttendeeDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(SummitAttendeeDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func ticketTypeDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(TicketTypeDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func imageDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(ImageDeserializer.self)
    }
    
    public dynamic func deserializerStorage() -> AnyObject {
        return TyphoonDefinition.withClass(DeserializerStorage.self){
            (definition) in
            
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    public dynamic func summitDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(SummitDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func companyDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(CompanyDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
        }
    }
    
    public dynamic func eventTypeDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(EventTypeDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            
        }
    }
    
    public dynamic func summitTypeDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(SummitTypeDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            
        }
    }
    
    public dynamic func locationDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(LocationDeserializer.self) {
            (definition) in
            
        }
    }
    
    public dynamic func venueDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(VenueDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func venueRoomDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(VenueRoomDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func summitEventDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(SummitEventDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func presentationDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(PresentationDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func trackDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(TrackDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
        }
    }
    
    public dynamic func memberDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(MemberDeserializer.self) {
            (definition) in
        
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    public dynamic func presentationSpeakerDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(PresentationSpeakerDeserializer.self) {
            (definition) in

            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
        }
    }
    
    public dynamic func tagDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(TagDeserializer.self) {
            (definition) in
            
        }
    }
    
    public dynamic func genericDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(GenericDataStore.self) {
            (definition) in
            
        }
    }
}