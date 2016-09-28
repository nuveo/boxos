#!/bin/sh

apt_url="https://apt.dockerproject.org"
gpg_fingerprint="58118E89F3A912897C070ADBF76221572C52609D"
key_servers="
ha.pool.sks-keyservers.net
pgp.mit.edu
keyserver.ubuntu.com
"
lsb_dist=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'id' | cut -d ':' -f 2 | tr -d '[[:space:]]')
dist_version=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'codename' | cut -d ':' -f 2 | tr -d '[[:space:]]')

aptitude update && aptitude upgrade
aptitude install sudo apt-transport-https ca-certificates

for key_server in $key_servers ; do
	apt-key adv --keyserver hkp://${key_server}:80 --recv-keys ${gpg_fingerprint} && break
done
apt-key adv -k ${gpg_fingerprint} >/dev/null
mkdir -p /etc/apt/sources.list.d
echo deb \[arch=$(dpkg --print-architecture)\] ${apt_url}/repo ${lsb_dist}-${dist_version} ${repo} > /etc/apt/sources.list.d/docker.list
sleep 3; aptitude update; aptitude install -y -q docker-engine
service docker start
docker run hello-world
curl -L https://github.com/docker/compose/releases/download/1.8.0/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
