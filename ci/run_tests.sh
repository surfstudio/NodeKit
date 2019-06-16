xcodebuild test \
-workspace NodeKit.xcworkspace \
-scheme NodeKit \
-configuration "Debug" \
-sdk iphonesimulator \
-enableCodeCoverage YES \
-destination 'platform=iOS Simulator,name=iPhone 5s,OS=12.2' | xcpretty -c