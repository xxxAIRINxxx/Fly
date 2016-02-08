//
//  GCDTests.swift
//  FlyTests
//
//  Created by xxxAIRINxxx on 2016/02/06.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import XCTest
@testable import Fly

class GCDTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMainQueue() {
        XCTAssertTrue(GCD.Main.queue === dispatch_get_main_queue(), "on main queue")
    }
    
    func testBackgroundQueue() {
        let expectation = expectationWithDescription("")
        
        dispatch_async(GCD.Background.queue) {
            XCTAssertEqual(qos_class_self(), QOS_CLASS_BACKGROUND, "on background queue")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testUserInteractiveQueue() {
        let expectation = expectationWithDescription("")
        
        dispatch_async(GCD.UserInteractive.queue) {
            XCTAssertEqual(qos_class_self(), QOS_CLASS_USER_INTERACTIVE, "on user interactive queue")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testUserInitiatedQueue() {
        let expectation = expectationWithDescription("")
        
        dispatch_async(GCD.UserInitiated.queue) {
            XCTAssertEqual(qos_class_self(), QOS_CLASS_USER_INITIATED, "on user initiated queue")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testUtilityQueue() {
        let expectation = expectationWithDescription("")
        
        dispatch_async(GCD.Utility.queue) {
            XCTAssertEqual(qos_class_self(), QOS_CLASS_UTILITY, "on utility queue")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testDefaultQueue() {
        let expectation = expectationWithDescription("")
        
        dispatch_async(GCD.Default.queue) {
            XCTAssertEqual(qos_class_self(), QOS_CLASS_DEFAULT, "on default queue")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testCustomQueue() {
        let serialQueue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL)
        let queue = GCD.Custom(queue: serialQueue)
        
        XCTAssertTrue(queue.queue === serialQueue, "on custom queue")
        
        let expectation = expectationWithDescription("")
        dispatch_async(GCD.Background.queue) {
            XCTAssertTrue(queue.queue === serialQueue, "on custom queue")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
}
