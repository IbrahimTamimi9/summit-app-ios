//
//  MemberProfileInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileInteractor {
    func getCurrentMember() -> Member?
    func getMember(memberId: Int, completionBlock : (Member?, NSError?) -> Void)
    func isFullProfileAllowed(member: Member) -> Bool
    func requestFriendship(memberId: Int, completionBlock: (NSError?) -> Void)
}

public class MemberProfileInteractor: NSObject, IMemberProfileInteractor {
    var memberDataStore: IMemberDataStore!
    var session: ISession!

    let kCurrentMember = "currentMember"

    public override init() {
        super.init()
    }
    
    public init(session: ISession, memberDataStore: IMemberDataStore) {
        self.session = session
        self.memberDataStore = memberDataStore
    }
    
    public func getMember(memberId: Int, completionBlock : (Member?, NSError?) -> Void) {
        memberDataStore.getById(memberId, completionBlock: completionBlock)
    }

    public func getCurrentMember() -> Member?{
        let member = session.get(kCurrentMember) as? Member
        return member
    }
    
    public func isFullProfileAllowed(member: Member) -> Bool {
        var allow = false
        if let currentMember = getCurrentMember() as Member? {
            if (currentMember.id == member.id) {
                allow = true
            }
            else if (currentMember.isFriend(member)) {
                allow = true
            }
        }
        return allow
    }
    
    public func requestFriendship(memberId: Int, completionBlock: (NSError?) -> Void) {
        completionBlock(nil)
    }
}
