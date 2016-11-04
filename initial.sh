#!/bin/sh

gpg_fingerprint="58118E89F3A912897C070ADBF76221572C52609D"
key_servers="
ha.pool.sks-keyservers.net
pgp.mit.edu
keyserver.ubuntu.com
"

aptitude update && aptitude upgrade
aptitude install sudo apt-transport-https ca-certificates htop iotop iptraf

for key_server in $key_servers ; do
	apt-key adv --keyserver hkp://${key_server}:80 --recv-keys ${gpg_fingerprint} && break
done
apt-key adv -k ${gpg_fingerprint} >/dev/null
mkdir -p /etc/apt/sources.list.d
echo deb https://apt.dockerproject.org/repo debian-jessie main > /etc/apt/sources.list.d/docker.list
sleep 3; aptitude update; aptitude install -y -q docker-engine
service docker start
docker run hello-world
curl -L https://github.com/docker/compose/releases/download/1.8.0/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose

echo "CUSTOM BASH"
echo 'PS1="\e[0;32m\]\u@\h \w >\e[0m\] "' > /root/.bash_profile
echo 'alias ll="ls --color -l"' >> /root/.bash_profile
set -o history
