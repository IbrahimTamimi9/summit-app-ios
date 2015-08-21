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
        
        realm.write {
            self.realm.deleteAll()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_getByUserName_userExistOnLocalDatabase_ReturnsCorrectMember() {
        // Arrange
        let summitDataStoreAssembly = SummitDataStoreAssembly().activate();
        let summitDataStore = summitDataStoreAssembly.summitDataStore() as! SummitDataStore
        summitDataStore.getAll(){
            (result) in
        }
        
        let expectation = expectationWithDescription("async load")
        let memberDataStoreAssembly = MemberDataStoreAssembly().activate();
        let memberDataStore = memberDataStoreAssembly.memberDataStore() as! MemberDataStore
        let email = "enzo@riverplate.com"
        
        // Act
        memberDataStore.getByEmail(email){
            (result) in
            
            // Assert
            XCTAssertEqual(1, self.realm.objects(Member.self).count)
            let member = self.realm.objects(Member.self).first
            XCTAssertEqual(email, member?.email)
            XCTAssertEqual(1, member?.bookmarkedEvents.count)
            XCTAssertEqual(1, member?.scheduledEvents.count)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
