//
//  ViewController.swift
//  SwiftPushSample
//
//  Created by DX173-XL on 2015-09-23.
//  Copyright © 2015 DX123-XL. All rights reserved.
//

import UIKit
import PCFPush

let kLogNotification = "PCF_PUSH_SWIFT_LOG_NOTIFICATION"

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = ""
    }

    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onLogNotification:", name: kLogNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func onLogNotification(notification: NSNotification) {
        if let logLine = notification.object as? String {
            if textView.text != nil {
                textView.text! += "\n\n" + logLine
            } else {
                textView.text = logLine
            }
        }
    }

    @IBAction func sendButtonPressed(sender: UIBarButtonItem) {

        let appUuid = "96afc5d9-f432-42e8-8095-d02df66bcad2"
        let apiKey = "5b212365-5e64-4b52-bf13-bb00e5ab53e0"

        let request = NSMutableURLRequest(URL: NSURL(string:"http://push-api.gulch.cf-app.com/v1/push")!)
        let session = NSURLSession.sharedSession()

        request.HTTPMethod = "POST"

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .LongStyle
        let message = [ "body":"This message was sent to the PCF Push back-end server at " + dateFormatter.stringFromDate(NSDate()) ]
        let target = [ "platform":"ios", "devices":[ PCFPush.deviceUuid() ]]
        let requestBody = [ "message":message, "target":target]

        let httpBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options:[])
        if httpBody == nil {
            ViewController.addLogMessage("ERROR: Not able to serialize JSON")
            return
        }
        request.HTTPBody = httpBody!
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.addValue(getBasicAuth(appUuid, apiKey: apiKey), forHTTPHeaderField:"Authorization")

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if response != nil {
                ViewController.addLogMessage("Push POST response: \(response!)")
            }
        }
        task.resume()
    }

    func getBasicAuth(appUuid:String, apiKey:String) -> String {
        let authStr = appUuid + ":" + apiKey
        let authData = authStr.dataUsingEncoding(NSUTF8StringEncoding)
        return "Basic " + authData!.base64EncodedStringWithOptions([])
    }

    class func addLogMessage(logMessage: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(kLogNotification, object:logMessage)
    }
}

