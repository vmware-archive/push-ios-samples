#!/bin/bash

set -ex

# Produce the build archive
xcodebuild \
  -workspace PushSample.xcworkspace \
  -scheme PushSample \
  -archivePath build/PushSample.xcarchive \
  archive

# Exports the build archive as an IPA file
xcodebuild \
  -exportArchive \
  -archivePath build/PushSample.xcarchive \
  -exportPath build/PushSample \
  -exportOptionsPlist scripts/sample-app-export-options.plist
