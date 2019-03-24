#!/bin/bash
cd /home/guest/stage/CoreNetKit/TestServer/src/TestServer
go get github.com/gorilla/mux

nohup go run TestServer.go