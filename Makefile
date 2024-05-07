init:
	# Install bundler if not installed
	if ! gem spec bundler > /dev/null 2>&1; then\
  		echo "bundler gem is not installed!";\
  		-sudo gem install bundler -v "1.17.3";\
	fi
	-bundle install --path .bundle

## Used to build target. Usually, it is not called manually, it is necessary for the CI to work.
build:
	xcodebuild clean build -project ./NodeKit/NodeKit.xcodeproj -scheme NodeKit -sdk iphonesimulator | bundle exec xcpretty -c

## Used to build target with SPM dependencies. Usually, it is not called manually, it is necessary for the CI to work.
spm_build:
	cd ./NodeKit && swift package clean
	cd ./NodeKit && swift build --sdk "`xcrun -sdk iphonesimulator --show-sdk-path`" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios17.4-simulator" -Xswiftc "-lswiftUIKit"

## Run tests and create coverage report
test:
	rm -rf DerivedData
	mkdir -p CoverageReports
	xcodebuild test -project ./NodeKit/NodeKit.xcodeproj -scheme NodeKit -derivedDataPath DerivedData -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO -enableCodeCoverage YES -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.4' | bundle exec xcpretty -c
	./xcresultparser/xcresultparser --output-format cobertura DerivedData/Logs/Test/*.xcresult > ./CoverageReports/coverage.xml

## Created documentation by comments from code
doc:
	bundle exec jazzy --clean --build-tool-arguments -project,./NodeKit/NodeKit.xcodeproj,-scheme,NodeKit,-sdk,iphonesimulator --output "docs"

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)


TARGET_MAX_CHAR_NUM=20
## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
