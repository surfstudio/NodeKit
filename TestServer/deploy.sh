#!/bin/bash
cd /home/guest/stage/CoreNetKit/TestServer/src/TestServer
go get github.com/gorilla/mux
cat "RUN SERVER"
go run TestServer.go &