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

    // This method requests that a log message be added to the screen.
    class func addLogMessage(logMessage: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(kLogNotification, object:logMessage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.editable = false
        textView.selectable = false
        textView.attributedText = nil
        if let navigationController = self.navigationController {
            navigationController.toolbarHidden = false
            
            let sendButton = UIBarButtonItem(title: "Send Message", style: .Plain, target: self, action: "sendButtonPressed")
            let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let unregisterButton = UIBarButtonItem(title: "Unregister", style: .Plain, target: self, action: "unregisterButtonPressed")
            
            self.setToolbarItems([unregisterButton, space, sendButton], animated: false)
        }
    }

    override func viewDidAppear(animated: Bool) {
        // Listen for log message notifications when the view controller is visible
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onLogNotification:", name: kLogNotification, object: nil)
        ViewController.addLogMessage("PCF Push SDK version is \(PCFPush.sdkVersion()).")
    }

    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // This method adds a log message to the screen.
    func onLogNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            if let logLine = notification.object as? String {
                if self.textView.text != nil && self.textView.text.characters.count > 0 {
                    self.textView.text! += "\n\n" + logLine
                    let bottom = NSMakeRange(self.textView.attributedText!.length - 1, 1)
                    self.textView.scrollRangeToVisible(bottom)
                } else {
                    self.textView.text = logLine
                }
            }
        })
    }

    func sendButtonPressed() {
        //
        // Set the appUuid, apiKey, and serviceUrl to match the configuration of your instance of the Push Notification Service API
        // in order to SEND push messages using the Swift Sample App.
        //
        // In order to REGISTER for push notifications you will need to enter your platformUuid, platformSecret and serviceUrl
        // in the Pivotal.plist file.
        //
        let appUuid = "44d26dcd-9abe-4bbb-b424-097985ac6ec5"
        let apiKey = "f60dee44-0ff1-45ca-97e1-0790090970b3"
        let serviceUrl = "http://push-api.gulch.cf-app.com"
        
        if let deviceUuid = PCFPush.deviceUuid() {

            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: NSURL(string:"\(serviceUrl)/v1/push")!)
            request.HTTPMethod = "POST"

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .LongStyle
            dateFormatter.timeStyle = .LongStyle
            let message = [ "body":"This message was sent to the PCF Push back-end server at " + dateFormatter.stringFromDate(NSDate()) ]
            let target = [ "platform":"ios", "devices":[ deviceUuid ]]
            let requestBody = [ "message":message, "target":target]

            let httpBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options:[])
            if httpBody == nil {
                ViewController.addLogMessage("ERROR: Not able to serialize JSON")
                return
            }
            request.HTTPBody = httpBody!
            request.addValue("application/json", forHTTPHeaderField:"Content-Type")
            request.addValue(getBasicAuth(appUuid, apiKey: apiKey), forHTTPHeaderField:"Authorization")

            ViewController.addLogMessage("Sending push message...")

            let task = session.dataTaskWithRequest(request) { data, response, error in
                if let httpUrlResponse = response as? NSHTTPURLResponse {
                    if httpUrlResponse.statusCode != 200 {
                        ViewController.addLogMessage("Error POSTING push message \(response)")
                    }
                }
            }
            task.resume()
            
        } else {
            ViewController.addLogMessage("You must be registered before you can send a push notification.")
        }
    }
    
    func unregisterButtonPressed() {
        ViewController.addLogMessage("Unregistering push notifications...")
        PCFPush.unregisterFromPCFPushNotificationsWithSuccess({
            ViewController.addLogMessage("Successfully unregistered.")},
            failure: { error in
                if let e = error {
                    ViewController.addLogMessage("Failed to unregister: \(e)")
                } else {
                    ViewController.addLogMessage("Failed to unregister.")
                }
        })        
    }

    func getBasicAuth(appUuid:String, apiKey:String) -> String {
        let authStr = appUuid + ":" + apiKey
        let authData = authStr.dataUsingEncoding(NSUTF8StringEncoding)
        return "Basic " + authData!.base64EncodedStringWithOptions([])
    }
}

