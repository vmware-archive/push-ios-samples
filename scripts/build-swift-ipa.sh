#!/bin/bash

set -ex

# Produce the build archive
xcodebuild \
  -project PushSample.xcodeproj \
  -scheme SwiftPushSample \
  -archivePath build/SwiftPushSample.xcarchive \
  archive

# Exports the build archive as an IPA file
xcodebuild \
  -exportArchive \
  -archivePath build/SwiftPushSample.xcarchive \
  -exportPath build/SwiftPushSample \
  -exportOptionsPlist scripts/sample-app-export-options.plist
