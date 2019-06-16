eval "$(ssh-agent -s)"
chmod 600 ssh/id_rsa
echo "Host lastsprint.dev\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
ssh-add ssh/id_rsa