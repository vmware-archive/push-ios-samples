#!/bin/bash

set -ex

xcodebuild \
  -workspace PushSample.xcworkspace \
  -scheme "PushSample" \
  -destination platform='iOS Simulator',name="${XCODE_SIMULATOR_NAME}",OS="${XCODE_OS_VERSION}" \
  clean build
