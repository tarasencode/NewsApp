//
//  NewsAppTests.swift
//  NewsAppTests
//
//  Created by oleG on 27/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import XCTest
@testable import NewsApp

class NewsAppTests: XCTestCase {
    
    func testFetchChannels() {
        let expect = expectation(description: "Channels download succeed")
        
        Channel.fetchChannels { (serverChannels) in
            XCTAssertNotNil(serverChannels, "Error. Can't get channels from server")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "Test timed out. \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testFetchArticles() {
        let expect = expectation(description: "Articles download succeed")
        
        Channel.fetchChannels { (serverArticles) in
            XCTAssertNotNil(serverArticles, "Error. Can't get articless from server")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "Test timed out. \(String(describing: error?.localizedDescription))")
        }
    }
}
