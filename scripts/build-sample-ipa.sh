#!/bin/bash

set -ex

# Produce the build archive
xcodebuild \
  -workspace PushSample.xcworkspace \
  -scheme PushSample \
  -archivePath build/PushSample.xcarchive \
  -xcconfig PushSample/ci-config.xcconfig \
  archive

# Exports the build archive as an IPA file
xcodebuild \
  -exportArchive \
  -xcconfig PushSample/ci-config.xcconfig \
  -archivePath build/PushSample.xcarchive \
  -exportPath build/PushSample \
  -exportOptionsPlist scripts/sample-app-export-options.plist
