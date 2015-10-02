//
//  MemberDataStoreTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class MemberDataStoreTests: XCTestCase {
    
    var realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        try! realm.write {
            self.realm.deleteAll()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_getById_userExistOnLocalDatabase_ReturnsCorrectMember() {
        // Arrange
        let memberId = 1
        let member = Member()
        member.id = memberId
        try! realm.write {
            self.realm.add(member)
        }
        
        let expectation = expectationWithDescription("async load")
        let memberDataStoreAssembly = MemberDataStoreAssembly().activate();
        let memberDataStore = memberDataStoreAssembly.memberDataStore() as! MemberDataStore
        
        // Act
        memberDataStore.getById(memberId){
            (result) in
            
            // Assert
            XCTAssertEqual(1, self.realm.objects(Member.self).count)
            let member = self.realm.objects(Member.self).first
            XCTAssertEqual(memberId, member?.id)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func test_addEventToMemberShedule_succeedAddingEvent_ReturnsAddedEventAndNoError() {
        // Arrange
        var event = SummitEvent()
        event.id = 1
        try! realm.write {
            self.realm.add(event)
        }
        
        let expectation = expectationWithDescription("async load")
        let memberDataStoreAssembly = MemberDataStoreAssembly().activate();
        let memberDataStore = memberDataStoreAssembly.memberDataStore() as! MemberDataStore
        let memberId = 1
        let member = Member()
        member.id = 1
        member.attendeeRole = SummitAttendee()
        try! realm.write {
            self.realm.add(member)
        }
        event = self.realm.objects(SummitEvent.self).filter("id = \(1)").first!
        
        // Act
        memberDataStore.addEventToMemberShedule(member, event: event) { member, error in
            // Assert
            XCTAssertEqual(1, self.realm.objects(Member.self).filter("id = \(memberId)").first!.attendeeRole!.scheduledEvents.first!.id)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}