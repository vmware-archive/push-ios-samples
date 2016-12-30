//
//  PushSampleUITests.swift
//  PushSampleUITests
//
//  Created by Pivotal DX256 on 2016-12-29.
//  Copyright © 2016 DX123-XL. All rights reserved.
//

import XCTest

class PushSampleUITests: XCTestCase , URLSessionDelegate {
    
    var app = XCUIApplication();
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIApplication().launch()
        app = XCUIApplication();
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func waitForElement(_ element: XCUIElement, waitTime: TimeInterval = 15) {
        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: waitTime, handler: nil)
    }
    
    func sendPush(_ message: String, scheduledTime: TimeInterval? = nil) throws {
        // make api call to let server to send push
        let todoEndpoint: String = "https://push-api.zeus.push.gcp.cf-app.com/v1/push"
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }

        
        var json: [String: Any] = ["message": ["body": message], "target": ["platform": "ios"]]
        if (scheduledTime != nil) {
            json["scheduleAt"] = "\(Int64(scheduledTime! * 1000))"
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let auth = "d71c0f28-3673-460d-9297-e0f4f598b44c:932b9973-b5db-4a54-a2b1-a4075e868983".data(using: String.Encoding.utf8)?.base64EncodedString()
        
        urlRequest.setValue("Basic \(auth!)", forHTTPHeaderField: "Authorization")
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        
        print(urlRequest.allHTTPHeaderFields!)
        print(urlRequest.httpBody)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            print(data)
            print(response)
            print(error)
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
        }
        
        task.resume()

    
    }
    
    func testRegistersToBackend() {
        let registrationPredicate = NSPredicate(format: "label CONTAINS 'CF registration succeeded.'")
        
        let registrationText = app.tables.staticTexts.element(matching: registrationPredicate)
        
        waitForElement(registrationText)
    }

    
    func testReceivePushFromBackend() throws {
        let timestamp = Date().timeIntervalSince1970
        let message = "Automated test push - \(timestamp)"
        
        try sendPush(message)
        
        let pushPredicate = NSPredicate(format: "label CONTAINS 'Automated test push - \(timestamp)'")
        let pushText = app.tables.staticTexts.element(matching: pushPredicate)
        
        waitForElement(pushText)
    }

    func testReceiveScheduledPushFromBackend() throws {
        let timestamp = Date().timeIntervalSince1970
        let message = "Automated Scheduled test push - \(timestamp)"
        let scheduleTime = TimeInterval(timestamp + 75)
        
        try sendPush(message, scheduledTime: scheduleTime)
        
        let pushPredicate = NSPredicate(format: "label CONTAINS 'Automated Scheduled test push - \(timestamp)'")
        let pushText = app.tables.staticTexts.element(matching: pushPredicate)
        
        waitForElement(pushText, waitTime: 120)
    }
}
