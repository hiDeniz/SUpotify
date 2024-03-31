//
//  supotify55Tests.swift
//  supotify55
//
//  Created by Ayça Ataer on 20.01.2024.
//
/*
import XCTest
@testable import supotify55
// URLSessionProtocol to abstract URLSession
protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}


extension URLSession: URLSessionProtocol {}


class MockURLSession: URLSessionProtocol {
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(nextData, nextResponse, nextError)
        return nextDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
}


class LoginTests: XCTestCase {
    var apicaller: APICaller!

    override func setUp() {
        super.setUp()
        apicaller = APICaller() // Make sure APICaller has the loginPostRequest method implemented.
    }

    override func tearDown() {
        apicaller = nil
        super.tearDown()
    }

    func testLoginSuccessForExistingUser() {
        let mockSession = MockURLSession()
        let email = "yusuferen2329@gmail.com"
        let password = "123"
        
        mockSession.nextData = "{\"message\": true}".data(using: .utf8)
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8008/login")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let expectation = XCTestExpectation(description: "Login for existing user completes successfully")
        
        // Update the call to match the expected method signature
        apicaller.loginPostRequest(email: email, password: password) { success in
            XCTAssertTrue(success, "Login should succeed for existing user")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }


    func testLoginFailureForNonExistingUser() {
        let mockSession = MockURLSession()
        let email = "doesnotexist@gmail.com"
        let password = "55"
        
        mockSession.nextData = "{\"message\": false}".data(using: .utf8)
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8008/login")!, statusCode: 401, httpVersion: nil, headerFields: nil)

        let expectation = XCTestExpectation(description: "Login for non-existing user fails")
        apicaller.loginPostRequest(email: email, password: password) { success in
            XCTAssertFalse(success, "Login should fail for non-existing user")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

*/
