#!/bin/bash
set -e
NEBULA_DIST=https://github.com/slackhq/nebula/releases/download/v1.2.0/nebula-linux-arm-7.tar.gz
SAMPLE_CONFIG=https://raw.githubusercontent.com/slackhq/nebula/v1.2.0/examples/config.yml

[ -d bin ] || {
	echo 'Creating "bin" directory'
	mkdir bin
}
[ -f bin/nebula ] || {
	echo Downloading nebula dist from $NEBULA_DIST
	curl "$NEBULA_DIST" -sL -o - | tar -xzf - -C bin --no-same-owner 
	chmod 0755 bin/nebula*
}

[ -d conf ] || {
	echo 'Creating "conf" directory'
	mkdir conf
}
[ -f conf/config.yml ] || {
	echo No config.yml found, downloading sample
	curl -sL "$SAMPLE_CONFIG" -o conf/config.yml
}
echo "Creating systemd service definition from template"
sed -e "s:%%GIT_DIR%%:$PWD:g" nebula.service.template > nebula.service 

echo "Symlinking rsyslog & systemd configurations into /etc" 
ln -s $PWD/nebula.service /etc/systemd/system/
ln -s $PWD/nebula-syslog.conf /etc/rsyslog.d/10-nebula.conf
echo Restarting syslog
systemctl restart syslog 
echo Enabling nebula
systemctl enable nebula

echo Please review $PWD/conf/config.yml and '"systemctl start nebula"' when ready.

