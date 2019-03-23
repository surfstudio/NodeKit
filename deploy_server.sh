scp -i ssh/id_rsa -P 22334 -r TestServer guest@lastsprint.dev:/home/guest/stage/CoreNetKit
curl lastsprint.dev:8844/shutdown
ssh -i ssh/id_rsa \
-p 22334 \
guest@lastsprint.dev \
sh stage/CoreNetKit/TestServer/deploy.sh

exit