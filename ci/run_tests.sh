xcodebuild test \
-workspace NodeKit.xcworkspace \
-scheme NodeKit \
-configuration "Debug" \
-sdk iphonesimulator \
-enableCodeCoverage YES \
-destination 'platform=iOS Simulator,name=iPhone 8,OS=12.1' | xcpretty -c