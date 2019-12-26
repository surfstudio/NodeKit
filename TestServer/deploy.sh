#!/bin/bash
cd /home/guest/stage/CoreNetKit/TestServer
echo 'CD COMPLETE'
go build .
echo 'BUILD COMPLETE'
./TestServer
echo 'RUN'
echo '\n'