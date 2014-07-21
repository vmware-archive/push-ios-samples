Pivotal Mobile Services Suite Push SDK Sample for iOS
=====================================================

The Push SDK requires iOS 6.0 or greater.

Push SDK Usage
--------------

For more information please visit the [docs site](https://github.com/cfmobile/docs-pushnotifications-ios)


Device Requirements
-------------------

The device must be registered on a developer profile which includes push notifications for the app bundle id.


Sample Application
------------------

This application has a visible UI that can be used to demonstrate and exercise the features of the Push SDK.

You can use this sample application to test registration against the Apple Push Notification Service (APNS) and the Pivotal Mobile Services Suite back-end server for push messages.  Although not currently supported by the library itself, you can also send and receive push messages with the sample application.

Before running this application you will need to create your own certificate, provisioning profile, and application on the Apple Developer iOS Member Center.

Watch the log output in the sample application's display to see what the Push library is doing in the background.  This log output should also be visible in the iOS device console (for debug builds), but the sample application registers a "listener" with the Push Library's logger so it can show you what's going on.

On launch, the sample application will ask the Push Library to register the device. If the device is not already registered, then you should see a lot of output scroll by as the library registers with both APNS and Pivotal MSS Push Server.  If the device is already registered then the output should be shorter.

You can clear the locally saved registration data with the "Clear Current Registration" button on the Settings screen. Clearing the registration data will force a full registration the next time that you press the "Register" button.

You can copy the contents of the log to the device clipboard by pressing the "Copy" button on the toolbar.  This feature can be useful if you want to email someone a device log, copy some of the JSON from a log message, or get one of the device tokens, for example.

You can change the registration preferences at run-time by pressing the "Settings" tool bar button.  Selecting this item will load the Settings screen.  This screen will allow you to modify the three values passed to the library initialization method above.  You can change the hard coded values by editing the definitions in the `Settings.m` file in the Sample application.

You can reset the registration preferences to the default values by selecting the "Reset to Defaults" action bar item in the Settings screen.

The sample application (not the library) is also set up to receive push messages once the device has been registered with APNS and PCF.  Although the library does not support receiving push messages at this time (since the Apple framework already provides very straightforward example code that you can copy into your application), the sample application does as a demonstration to show that the "system works".  It can be useful for testing your registration set up, or for testing the server itself.