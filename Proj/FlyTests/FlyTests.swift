//
//  FlyTests.swift
//  FlyTests
//
//  Created by xxxAIRINxxx on 2016/02/06.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import XCTest
@testable import Fly

enum TestErrortype: ErrorType {
    case TestError
}

class FlyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGCD() {
        let expectation = expectationWithDescription("")
        
        Fly.onFirst { result in
            XCTAssertEqual(qos_class_self(), qos_class_main(), "on main queue")
            return FlyResult.Next(result: nil)
            }.onNext(GCD.Background) { result in
                XCTAssertEqual(qos_class_self(), QOS_CLASS_BACKGROUND, "on background queue")
                return FlyResult.Next(result: nil)
            }.onNext(GCD.UserInteractive) { result in
                XCTAssertEqual(qos_class_self(), QOS_CLASS_USER_INTERACTIVE, "on user interactive queue")
                return FlyResult.Next(result: nil)
            }.onNext(GCD.UserInitiated) { result in
                XCTAssertEqual(qos_class_self(), QOS_CLASS_USER_INITIATED, "on user initiated queue")
                return FlyResult.Next(result: nil)
            }.onNext(GCD.Default) { result in
                XCTAssertEqual(qos_class_self(), QOS_CLASS_DEFAULT, "on default queue")
                return FlyResult.Finish(result: nil)
            }.onComplete(GCD.Main) { result in
                XCTAssertEqual(qos_class_self(), qos_class_main(), "on main queue")
                expectation.fulfill()
            }.fly(0)
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testNext() {
        let expectation = expectationWithDescription("")
        
        Fly.onFirst { result in
            let conut = (result as! Int) + 1
            return FlyResult.Next(result: conut)
            }.onNext(GCD.Background) { result in
                let conut = (result as! Int)
                XCTAssertTrue(conut == 1, "")
                return FlyResult.Next(result: conut + 1)
            }.onNext(GCD.UserInteractive) { result in
                let conut = (result as! Int)
                XCTAssertTrue(conut == 2, "")
                return FlyResult.Next(result: conut + 1)
            }.onNext(GCD.Default) { result in
                let conut = (result as! Int)
                XCTAssertTrue(conut == 3, "")
                return FlyResult.Finish(result: conut + 1)
            }.onComplete(GCD.Main) { result in
                let conut = (result as! Int)
                XCTAssertTrue(conut == 4, "")
                expectation.fulfill()
            }.fly(0)

        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testCancel() {
        let expectation = expectationWithDescription("")
        
        Fly.onFirst { result in
            return FlyResult.Next(result: result)
            }.onNext(GCD.Background) { result in
            return FlyResult.Cancel
            }.onCancel(GCD.UserInteractive) {
                expectation.fulfill()
            }.fly(0)
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testError() {
        let expectation = expectationWithDescription("")
        
        Fly.onFirst { result in
            return FlyResult.Next(result: result)
            }.onNext(GCD.Background) { result in
                return FlyResult.Error(Error: TestErrortype.TestError)
            }.onError { error in
                if case TestErrortype.TestError = error {
                    expectation.fulfill()
                } else {
                    XCTFail("testError failed")
                }
            }.fly(0)
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testBack() {
        let expectation = expectationWithDescription("")
        
        Fly.onFirst { result in
            let conut = (result as! Int) + 1
            return FlyResult.Next(result: conut)
            }.onNext(GCD.Background) { result in
                let conut = (result as! Int)
                if conut == 1 {
                    return FlyResult.Next(result: conut + 1)
                } else {
                    return FlyResult.Finish(result: conut)
                }
            }.onNext(GCD.UserInteractive) { result in
                let conut = (result as! Int)
                return FlyResult.Back(result: conut)
            }.onComplete(GCD.Main) { result in
                let conut = (result as! Int)
                XCTAssertTrue(conut == 2, "")
                expectation.fulfill()
            }.fly(0)
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testRetry() {
        let expectation = expectationWithDescription("")
        
        Fly.onFirst { result in
            let conut = (result as! Int) + 1
            return FlyResult.Next(result: conut)
            }.onNext(GCD.Background) { result in
                let conut = (result as! Int)
                if conut == 1 {
                    return FlyResult.Retry(result: conut + 1)
                } else {
                    return FlyResult.Finish(result: conut)
                }
            }.onComplete(GCD.Main) { result in
                let conut = (result as! Int)
                XCTAssertTrue(conut == 2, "")
                expectation.fulfill()
            }.fly(0)
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    func testRestart() {
        let expectation = expectationWithDescription("")
        
        Fly.onFirst { result in
            let conut = (result as! Int) + 1
            return FlyResult.Next(result: conut)
            }.onNext(GCD.Background) { result in
                let conut = (result as! Int)
                if conut == 1 {
                    return FlyResult.Retry(result: conut + 1)
                } else {
                    return FlyResult.Finish(result: conut)
                }
            }.onComplete(GCD.Main) { result in
                let conut = (result as! Int)
                XCTAssertTrue(conut == 2, "")
                expectation.fulfill()
            }.fly(0)
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
}
