scp -i
scp -i ssh/id_rsa -P 22334 -r TestServer guest@lastsprint.dev:/home/guest/stage/CoreNetKit
ssh -i ssh/id_rsa \
-p 22334 \
guest@lastsprint.dev \
cd stage/CoreNetKit/TestServer/src/TestServer \
go install \
cd ../../bin
setsid TestServer