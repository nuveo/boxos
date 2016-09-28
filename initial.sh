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

sh_c='sh -c'
if [ "$user" != 'root' ]; then
	if command_exists sudo; then
		sh_c='sudo -E sh -c'
	elif command_exists su; then
		sh_c='su -c'
	else
		cat >&2 <<-'EOF'
		Error: this installer needs the ability to run commands as root.
		We are unable to find either "sudo" or "su" available to make this happen.
		EOF
		exit 1
	fi
fi

$sh_c "aptitude update && aptitude upgrade"
$sh_c "aptitude install apt-transport-https ca-certificates"
for key_server in $key_servers ; do
	$sh_c "apt-key adv --keyserver hkp://${key_server}:80 --recv-keys ${gpg_fingerprint}" && break
done
$sh_c "apt-key adv -k ${gpg_fingerprint} >/dev/null"
$sh_c "mkdir -p /etc/apt/sources.list.d"
$sh_c "echo deb \[arch=$(dpkg --print-architecture)\] ${apt_url}/repo ${lsb_dist}-${dist_version} ${repo} > /etc/apt/sources.list.d/docker.list"
$sh_c 'sleep 3; aptitude update; aptitude install -y -q docker-engine'
$sh_c "service docker start"
$sh_c "docker run hello-world"
$sh_c "curl -L https://github.com/docker/compose/releases/download/1.8.0/run.sh > /usr/local/bin/docker-compose"
$sh_c "chmod +x /usr/local/bin/docker-compose"
