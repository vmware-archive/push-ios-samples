PCF Push SDK Sample for iOS
===========================

The PCF Push SDK requires iOS 8.0 or greater.

PCF Push SDK Usage
--------------

For more information please visit the [iOS Push docs site](https://docs.pivotal.io/push/ios).

Device Requirements
-------------------

The device must be registered on a developer profile which includes Push Notifications for the App Bundle ID.

Sample Application (Objective-C)
--------------------------------

This application has a visible UI that can be used to demonstrate and exercise the features of the Push SDK.  This application requires iOS 8.0 or greater.

Building the Sample App requires **Cocoapods 0.39.0**.

By default, this application uses Cocoapods to link to the PCF Push Client SDK.  If you want to link to the framework itself then please feel free to remove the Cocoapods settings in your working copy (please see instructions below).

You can use this sample application to test registration against the Apple Push Notification Service (APNS) and the Pivotal Mobile Services Suite back-end server for push messages.  Although not currently supported by the library itself, you can also send and receive push messages with the sample application.

Before running this application you will need to create your own certificate, provisioning profile, and application on the Apple Developer iOS Member Center.  Set up PCF Push Notification Service on some CF machine and set up an iOS Application and Platform in developer mode.  Copy the Platform UUID and Platform Secret into the Sample App's `Pivotal.plist` file (the `pivotal.push.platformUuidDevelopment` and `pivotal.push.platformSecretDevelopment` parameters).  Set the `pivotal.push.serviceUrl` parameter in the `Pivotal.plist` file to your Push API server URL (e.g.: "http://push-api.yourserver.com").

Watch the log output in the sample application's display to see what the Push library is doing in the background.  This log output should also be visible in the iOS device console (for debug builds), but the sample application registers a "listener" with the Push Library's logger so it can show you what's going on.

On launch, the sample application will ask the Push Library to register the device. If the device is not already registered, then you should see a lot of output scroll by as the library registers with both APNS and PCF Push Server.  If the device is already registered then the output should be shorter.

Press the "Send" bottom at the bottom left of the screen to send a push message.  You will need to set your Push API server URL, App UUID, and API Key in the `Settings.m` file.

You can find other actions by pressing the "Actions" button at the bottom-right of the screen:

 * Copy Log: You can copy the contents of the log to the device clipboard by pressing the "Copy" action.  This feature can be useful if you want to email someone a device log, copy some of the JSON from a log message, or get one of the device tokens, for example.
 * Clear Log: Clear the log on the screen.
 * Unregistration: You can unregister your device from push notifications by pressing the "Unregister" action.  Clearing the registration data will force a full registration the next time that you press the "Register" button.
 * Subscribe to Tag: If you want to test sending and receiving tagged push messages then you can use the "Subscribe to Tag" option to select one tag to subscribe to.  The Push Sample App only lets you be registered to one tag at a time (although the Push SDK itself allows you to be registered to many tags).
 * Unsubscribe from Tag: Use this option if you want to unsubcribe from push tags.
 * Send to Tag: Use this message to send a message to a specific tag.
 * Send with Category: This message will send a remote notification with the "ACTIONABLE" category.  The sample app responds to this category by showing several more actions (although these actions don't do anything).
 * Enable/Disable geofences: Use this option to enable or disable geofences.
 * About: Use this option to see the current version of the application.

The sample application (not the library) is also set up to receive push messages once the device has been registered with APNS and PCF.  Although the library does not support receiving push messages at this time (since the Apple framework already provides very straightforward example code that you can copy into your application), the sample application does as a demonstration to show that the "system works".  It can be useful for testing your registration set up, or for testing the server itself.

Swift Sample Application
------------------------

You can also find a sample application in the new Swift programming language.  This simple application demonstrates how to link to the PCF Push SDK framework in Swift applications.  This application will register for push notifications, enable geofences, and location services at start up.

This application requires iOS 8.0 or greater.

As above, create a new application on the Apple Developer iOS Member Center and the PCF Push Notification Service.  Set up the Swift Sample Application by entering the appropriate parameters in the `Pivotal.plist` file.

You can press the "Send" button at the top-right of the screen to try and send a push message.  Enter your App UUID, API Key, and Service URL into the appropriate variables in the `ViewController.swift` file.

The application will print remote notifications and triggered geofences to the screen as it runs.

Cocoapods
---------

The Sample Application uses Cocoapods to link to the PCF Push framework, by default. This is done mostly as a convenience to the project developers. It is our expectation that most developers will link to the PCF Push SDK as a framework, not via Cocoapods. However, please note that doing so will significantly limit the features available in the sample app. While the functionality of the Push Notification Service will be unaffected, the log messages on the device will no longer work. If you would like to locally change the sample app to use the framework directly, please try the following steps:

1. If you currently have the Push Sample Application workspace open then please close it.

1. If you have cloned the Push Sample repository then please start a new branch.  Please do not submit any pull requests that remove Cocoapods from the project.

1. Delete the following directories and all of their contents: PushSample.xcworkspace, Pods.

1. Delete the following files: Podfile, Podfile.lock.

1. Open the project file directly ("PushSample.xcodeproj").

1. Open the PushSample Project "Info" tab and navigate to the "Configurations" section.  Set the PushSample configuration to be based on "None" (instead of "Pods.debug"/"Pods.release") for both debug and release.

1. Open the PushSample Target "Build Phases" tab.  Delete the following build phases: Check Pods Manifest.lock, Embed Pods Frameworks, Copy Pods Resources.

1. Remove "libPods.a" from the "Link Binary with Libraries" section of the build phases.

1. Delete "libPods.a" from the "Frameworks" group in the project files listing.

1. Delete the "Pods" group in the project files listing.

1. Drop the PCFPush framework file into the project "Frameworks" group.  Ensure that "Copy items if needed" is checked.

1. Open the PushSample target "General" tab.  Remove "PCFPush.framework" from the list of Linked Frameworks and Libraries.  Add it to the list of Embedded Libraries instead.

1. Open the "LogTableViewController.m" source code file.  Comment out the #include for "PCFPushPersistentStorage.h", "PCFPushGeofencePersistentStore.h", and "PCFPushGeofenceRegistrar.h" and all lines of code that call the "PCFPushDebug setLogListener" method. Also set the "backEndDeviceID" to nil.

1. Also in the "LogTableViewController.m" source code file.  Comment out the #include for "PCFPushDebug.h" and all lines of code that call the "PCFPushLog" and "PCFPushCriticalLog" functions.

1. Open the "BackEndMessageRequest.m" source code file.  Comment out the #include for "PCFPushDebug.h" and all lines of code that call the "PCFPushLog" and "PCFPushCriticalLog" functions.

1. Open the "AppDelegate.m" source code file.  Comment out the #include for "PCFPushDebug.h" and all lines of code that call the "PCFPushLog" and "PCFPushCriticalLog" functions.

1. Open the "MapViewController.m" source code file.  Comment out the #include for "PCFPushDebug.h" and all lines of code that call the "PCFPushLog" and "PCFPushCriticalLog" functions.

Please note that in the future we intend to reduce (or completely remove) the Sample App's code dependencies on the private parts of the Push SDK so the code changes above should no longer be necessary.
