#!/bin/bash

set -ex

# Produce the build archive
xcodebuild \
  -project PushSample.xcodeproj \
  -scheme SwiftPushSample \
  -archivePath build/SwiftPushSample.xcarchive \
  -xcconfig SwiftPushSample/swift-ci-config.xcconfig \
  archive

# Exports the build archive as an IPA file
xcodebuild \
  -exportArchive \
  -xcconfig SwiftPushSample/swift-ci-config.xcconfig \
  -archivePath build/SwiftPushSample.xcarchive \
  -exportPath build/SwiftPushSample \
  -exportOptionsPlist scripts/sample-app-export-options.plist
