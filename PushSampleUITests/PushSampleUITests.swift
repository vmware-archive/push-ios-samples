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

        let path = Bundle.init(for: PushSampleUITests.self).path(forResource: "Pivotal", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)

        let appUuid = dict?["pivotal.push.applicationUuid"]! as! String
        let apiKey = dict?["pivotal.push.applicationApiKey"]! as! String
        let serviceUrl = dict?["pivotal.push.serviceUrl"]! as! String

        // make api call to let server to send push

        let apiEndpoint: String = "\(serviceUrl)/v1/push"
        print(apiEndpoint)
        guard let url = URL(string: apiEndpoint) else {
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
        let auth = "\(appUuid):\(apiKey)".data(using: String.Encoding.utf8)?.base64EncodedString()
        
        urlRequest.setValue("Basic \(auth!)", forHTTPHeaderField: "Authorization")
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        
        print(urlRequest.allHTTPHeaderFields!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            assert(response != nil, "Error: received nil response")
            assert(error == nil, "Error when sending a push \(error!)")
            assert(data != nil, "Error: did not receive data")
            
            print("DATA: ", String.init(data: data!, encoding: .utf8))
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
