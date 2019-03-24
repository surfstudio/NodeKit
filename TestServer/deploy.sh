#!/bin/bash
cd /home/guest/stage/CoreNetKit/TestServer/src/TestServer
echo 'CD COMPLETE'
go get github.com/gorilla/mux
echo 'GO GET COMPLETE'
nohup go run TestServer.go &
echo 'RAN'
echo '\n'