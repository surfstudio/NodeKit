#!/bin/bash
cd /home/guest/stage/CoreNetKit/TestServer/src/TestServer
echo 'CD COMPLETE'
go get github.com/gorilla/mux
go get gopkg.in/mgo.v2/bson
echo 'GO GET COMPLETE'
go run TestServer.go
echo 'RAN'
echo '\n'