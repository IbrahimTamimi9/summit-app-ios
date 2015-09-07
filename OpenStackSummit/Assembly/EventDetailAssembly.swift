//
//  EventDetailAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class EventDetailAssembly: TyphoonAssembly {
    var memberDataStoreAssembly: MemberDataStoreAssembly!
    
    dynamic func eventDetailWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailWireframe.self) {
            (definition) in
            
            definition.injectProperty("eventDetailViewController", with: self.eventDetailViewController())
        }
    }
    
    dynamic func eventDetailPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailPresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.eventDetailViewController())
            definition.injectProperty("interactor", with: self.eventDetailInteractor())
            definition.injectProperty("eventDetailDTOAssembler", with: self.eventDetailDTOAssembler())
        }
    }
    
    dynamic func eventDetailDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailDTOAssembler.self) {
            (definition) in
            
            definition.injectProperty("speakerDTOAssembler", with: self.speakerDTOAssembler())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.scheduleItemDTOAssembler())
        }
    }
    
    dynamic func speakerDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(SpeakerDTOAssembler.self)
    }
    
    dynamic func scheduleItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(ScheduleItemDTOAssembler.self)
    }
    
    dynamic func eventDetailInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailInteractor.self) {
            (definition) in
            
            definition.injectProperty("session", with: self.eventDetailSession())
            definition.injectProperty("eventDataStore", with: self.eventDataStore())
            definition.injectProperty("memberDataStore", with: self.memberDataStoreAssembly.memberDataStore())
        }
    }

    dynamic func eventDetailSession() -> AnyObject {
        return TyphoonDefinition.withClass(Session.self)
    }
    
    dynamic func eventDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(EventDataStore.self)
    }
    
    dynamic func eventDetailViewController() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.eventDetailPresenter())
        }
    }
    
    var applicationAssembly: ApplicationAssembly!
    
}


