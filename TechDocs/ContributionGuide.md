# Contribution Guide

This document describes what is contained in this repository.

It includes information on how to run tests, how the Continuous Integration (CI) works, available automations, and the general development workflow for NodeKit.

## CI

Currently, NodeKit uses Github Actions.

Each created PR goes through several stages during the build process:
- Project compilation - ensuring that the library is built using the `xcodebuild build` command.
- Compilation using Swift Packet Manager (SPM) - verifying that the library is built using the `swift build` command.
- Testing - running all library tests.
- Uploading test results to CodeCov.

Internal actions are performed using scripts from the `Makefile`.

## Integration Tests

In addition to Unit tests, NodeKit library has implemented a series of integration tests. 

Responses from the server are substituted by adding `URLProtocolMock` to `URLSessionConfiguration.protocolClasses`. This is already implemented in the `NetworkMock` class. To write integration tests, you only need to pass `NetworkMock().urlSession` to where it is required.

For more details, you can read [here](/TechDocs/Testing/NodeKitMock.md)