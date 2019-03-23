#!/bin/bash
curl 127.0.0.1:8811/shutdown
cd /home/guest/stage/CoreNetKit/TestServer/src/TestServer
go get github.com/gorilla/mux
setsid go run TestServer.go