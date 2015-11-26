//
//  MenuInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import Parse

@objc
public protocol IMenuInteractor {
    func login(completionBlock: (error: NSError?) -> Void)
    func logout(completionBlock: (error: NSError?) -> Void)
    func unsubscribeFromPushChannels(completionBlock: (succeeded: Bool, error: NSError?) -> Void)
}

public class MenuInteractor: NSObject, IMenuInteractor {
    var session : ISession!
    let kAccessToken = "access_token"
    let kCurrentMember = "currentMember"
    var securityManager: SecurityManager!
    var pushNotificationsManager: IPushNotificationsManager!
    
    public override init() {
        super.init()
    }

    public init(session: ISession) {
        self.session = session
    }
    
    public func login(completionBlock: (error: NSError?) -> Void) {
        securityManager.login() { error in
            if (error != nil) {
                completionBlock(error: error)
                return
            }
            
            self.pushNotificationsManager.subscribeToPushChannelsUsingContext(){ (succeeded: Bool, error: NSError?) in
                completionBlock(error: error)
            }
        }
    }

    public func logout(completionBlock: (error: NSError?) -> Void) {
        securityManager.logout() { error in
            if (error != nil) {
                completionBlock(error: error)
                return
            }
            
            self.pushNotificationsManager.unsubscribeFromPushChannels(){ (succeeded: Bool, error: NSError?) in
                completionBlock(error: error)
            }
        }
    }
    
    public func unsubscribeFromPushChannels(completionBlock: (succeeded: Bool, error: NSError?) -> Void) {
        pushNotificationsManager.unsubscribeFromPushChannels(completionBlock)
    }

}
