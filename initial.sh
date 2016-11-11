#!/bin/sh

OS=$(lsb_release -si)
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
VER=$(lsb_release -sr)

case $OS in
Ubuntu)
	OS="ubuntu"
	APT=apt
	case $VER in
	16.04)
		VER_NAME="xenial"
		;;
	14.04)
		VER_NAME="trusty"
		;;
	12.04)
		VER_NAME="precise"
		;;
	*)
		echo "Unsupported Ubuntu ${VER}, BoxOS recommend used Debian Jessie or Ubuntu 16.04"
		;;
	esac
	;;
Debian)
	OS="debian"
	APT=aptitude
	case $VER in
	8.*)
		VER_NAME="jessie"
		;;
	7.*)
		VER_NAME="wheezy"
		;;
	*)
		echo "Unsupported Debian ${VER}, BoxOS recommend used Debian Jessie or Ubuntu 16.04"
		;;
	esac
	;;
*)
	echo "Unsupported distribution, BoxOS recommend used Debian Jessie or Ubuntu 16.04"
	;;
esac

DOCKER_REPO="deb https://apt.dockerproject.org/repo ${OS}-${VER_NAME} main"
DOCKER_COMPOSE_VERSION="1.8.0"
gpg_fingerprint="58118E89F3A912897C070ADBF76221572C52609D"
key_servers="
ha.pool.sks-keyservers.net
pgp.mit.edu
keyserver.ubuntu.com
"

${APT} update && ${APT} upgrade -y
${APT} install -y sudo apt-transport-https ca-certificates locales htop iotop iptraf
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
LANG=en_US.utf8

for key_server in $key_servers ; do
        apt-key adv --keyserver hkp://${key_server}:80 --recv-keys ${gpg_fingerprint} && break
done
apt-key adv -k ${gpg_fingerprint} >/dev/null
mkdir -p /etc/apt/sources.list.d
echo ${DOCKER_REPO} > /etc/apt/sources.list.d/docker.list
sleep 3; ${APT} update -y; ${APT} install -y -q docker-engine
service docker start
docker run hello-world
curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose

echo "CUSTOM BASH"
echo 'PS1="\e[0;32m\]\u@\h \w >\e[0m\] "' > /root/.bash_profile
echo 'alias ll="ls --color -l"' >> /root/.bash_profile
set -o history
