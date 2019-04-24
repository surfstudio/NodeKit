xcodebuild test \
-workspace CoreNetKit.xcworkspace \
-scheme CoreNetKitIntegrationTests \
-configuration "Debug" \
-sdk iphonesimulator \
-enableCodeCoverage YES \
-destination 'platform=iOS Simulator,name=iPhone 8,OS=12.1' | xcpretty -c