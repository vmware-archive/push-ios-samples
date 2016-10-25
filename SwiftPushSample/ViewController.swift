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
    class func addLogMessage(_ logMessage: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kLogNotification), object:logMessage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        textView.isSelectable = false
        textView.attributedText = nil
        if let navigationController = self.navigationController {
            navigationController.isToolbarHidden = false
            
            let sendButton = UIBarButtonItem(title: "Send Message", style: .plain, target: self, action: #selector(sendButtonPressed))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let unregisterButton = UIBarButtonItem(title: "Unregister", style: .plain, target: self, action: #selector(unregisterButtonPressed))
            
            self.setToolbarItems([unregisterButton, space, sendButton], animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // Listen for log message notifications when the view controller is visible
        NotificationCenter.default.addObserver(self, selector: #selector(onLogNotification), name: NSNotification.Name(rawValue: kLogNotification), object: nil)
        ViewController.addLogMessage("PCF Push SDK version is \(PCFPush.sdkVersion()).")
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    // This method adds a log message to the screen.
    func onLogNotification(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
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
        let appUuid = "23a83339-b40b-453a-92da-92414321a7ab"
        let apiKey = "753a05ad-d88e-43b4-8819-7497d644c917"
        let serviceUrl = "http://push-api.kitkat.cf-app.com"
        
        if let deviceUuid = PCFPush.deviceUuid() {

            let session = URLSession.shared
            let request = NSMutableURLRequest(url: URL(string:"\(serviceUrl)/v1/push")!)
            request.httpMethod = "POST"

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .long
            let message = [ "body":"This message was sent to the PCF Push back-end server at " + dateFormatter.string(from: Date()) ]
            let target = [ "devices":[ deviceUuid ]]
            let requestBody = [ "message":message, "target":target] as [String : Any]

            let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options:[])
            if httpBody == nil {
                ViewController.addLogMessage("ERROR: Not able to serialize JSON")
                return
            }
            request.httpBody = httpBody!
            request.addValue("application/json", forHTTPHeaderField:"Content-Type")
            request.addValue(getBasicAuth(appUuid, apiKey: apiKey), forHTTPHeaderField:"Authorization")

            ViewController.addLogMessage("Sending push message...")

            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                if let httpUrlResponse = response as? HTTPURLResponse {
                    if httpUrlResponse.statusCode != 200 {
                        ViewController.addLogMessage("Error POSTING push message \(response)")
                    }
                }
            })
            task.resume()
            
        } else {
            ViewController.addLogMessage("You must be registered before you can send a push notification.")
        }
    }
    
    func unregisterButtonPressed() {
        ViewController.addLogMessage("Unregistering push notifications...")
        PCFPush.unregisterFromPCFPushNotifications(success: {
            ViewController.addLogMessage("Successfully unregistered.")},
            failure: { error in
                if let e = error {
                    ViewController.addLogMessage("Failed to unregister: \(e)")
                } else {
                    ViewController.addLogMessage("Failed to unregister.")
                }
        })        
    }

    func getBasicAuth(_ appUuid:String, apiKey:String) -> String {
        let authStr = appUuid + ":" + apiKey
        let authData = authStr.data(using: String.Encoding.utf8)
        return "Basic " + authData!.base64EncodedString(options: [])
    }
}

